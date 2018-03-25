#include <errno.h>
#include <getopt.h>
#include <limits.h>
#include <pcre.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

#include "../src/label_file.h"
#include "label_file2.h"

/*
 * File Format
 *
 * u32 - magic number
 * u32 - version
 * u32 - length of pcre version EXCLUDING nul
 * char - pcre version string EXCLUDING nul
 * u32 - number of stems
 * ** Stems
 *	u32  - length of stem EXCLUDING nul
 *	char - stem char array INCLUDING nul
 * u32 - number of regexs
 * ** Regexes
 *	u32  - length of upcoming context INCLUDING nul
 *	char - char array of the raw context
 *	u32  - length of the upcoming regex_str
 *	char - char array of the original regex string including the stem.
 *	u32  - mode bits for >= SELINUX_COMPILED_FCONTEXT_MODE
 *	       mode_t for <= SELINUX_COMPILED_FCONTEXT_PCRE_VERS
 *	s32  - stemid associated with the regex
 *	u32  - spec has meta characters
 *	u32  - The specs prefix_len if >= SELINUX_COMPILED_FCONTEXT_PREFIX_LEN
 *	u32  - data length of the pcre regex
 *	char - a bufer holding the raw pcre regex info
 *	u32  - data length of the pcre regex study daya
 *	char - a buffer holding the raw pcre regex study data
 */

static int read_binary_file(struct saved_data2 *data, const char *filename)
{
	FILE *bin_file;
	size_t len;
	uint32_t section_len;
	uint32_t i;
	int rc;

	bin_file = fopen(filename, "r");
	if (!bin_file) {
		perror("fopen bin_file");
		exit(EXIT_FAILURE);
	}

	/* discard magic number */
	rc = fseek(bin_file, sizeof(uint32_t), SEEK_CUR);
	if (rc) goto err;

	/* check correct version */
	len = fread(&section_len, sizeof(uint32_t), 1, bin_file);
	if (len != 1) goto err;
	if (section_len != SELINUX_COMPILED_FCONTEXT_MAX_VERS) {
		perror("Unsupported Version");
		goto err;
	}

	/* discard regex back-end version */
	len = fread(&section_len, sizeof(uint32_t), 1, bin_file);
	if (len != 1) goto err;
	rc = fseek(bin_file, sizeof(char) * section_len, SEEK_CUR);
	if(rc) goto err;

	/* discard regex arch string */
	len = fread(&section_len, sizeof(uint32_t), 1, bin_file);
	if (len != 1) goto err;
	rc = fseek(bin_file, sizeof(char) * section_len, SEEK_CUR);
	if(rc) goto err;

	/* read the number of stems coming */
	len = fread(&section_len, sizeof(uint32_t), 1, bin_file);
	if (len != 1) goto err;

	initialze_stems2(data, section_len);

	for (i = 0; i < section_len; i++) {
		char *stem;
		uint32_t stem_len;

		/* read the strlen (aka no nul) */
		len = fread(&stem_len, sizeof(uint32_t), 1, bin_file);
		if (len != 1) goto err;

		/* include the nul in the file */
		stem_len += 1;
		stem = malloc(sizeof(char) * stem_len);
		len = fread(stem, sizeof(char), stem_len, bin_file);
		if (len != stem_len) goto err;

		/* store stem */
		rc = store_stem2(data, stem, stem_len);
		if (rc < 0) goto err;
	}

	/* read the number of regexes coming */
	len = fread(&section_len, sizeof(uint32_t), 1, bin_file);
	if (len != 1) goto err;

	initialize_specs2(data, section_len);

	for (i = 0; i < section_len; i++) {
		char *context;
		char *regex_str;
		mode_t mode;
		int32_t stem_id;
		size_t metaChars_size = sizeof(int);
		size_t prefix_size = sizeof(int);
		uint32_t to_read;

		/* length of the context string (including nul) */
		len = fread(&to_read, sizeof(uint32_t), 1, bin_file);
		if (len != 1) goto err;

		/* original context string (including nul) */
		context = malloc(sizeof(char) * to_read);
		len = fread(context, sizeof(char), to_read, bin_file);
		if (len != to_read) goto err;

		/* length of the original regex string (including nul) */
		len = fread(&to_read, sizeof(uint32_t), 1, bin_file);
		if (len != 1) goto err;

		/* original regex string (including nul) */
		regex_str = malloc(sizeof(char) * to_read);
		len = fread(regex_str, sizeof(char), to_read, bin_file);
		if (len != to_read) goto err;

		/* binary F_MODE bits */
		len = fread(&to_read, sizeof(uint32_t), 1, bin_file);
		if (len != 1) goto err;
		mode = to_read;

		/* stem for this regex (could be -1) */
		len = fread(&stem_id, sizeof(stem_id), 1, bin_file);
		if (len != 1) goto err;

		/* discard spec's metaChar? */
		rc = fseek(bin_file, metaChars_size, SEEK_CUR);
		if (rc) goto err;

		/* discard SELINUX_COMPILED_FCONTEXT_PREFIX_LEN */
		rc = fseek(bin_file, prefix_size, SEEK_CUR);
		if (rc) goto err;

		/* size of the serialized pattern */
		len = fread(&to_read, sizeof(uint32_t), 1, bin_file);
		if (len != 1) goto err;

		/* discard serialized pattern */
		rc = fseek(bin_file, to_read, SEEK_CUR);
		if (rc) goto err;

		/* store spec */
		rc = store_spec2(data, regex_str, context, mode, stem_id);
		if (rc < 0) goto err;
	}

	rc = 0;
out:
	fclose(bin_file);
	return rc;
err:
	rc = -1;
	goto out;
}

static int write_text_file(struct saved_data2 *data, int fd)
{
	struct spec2 *specs = data->spec_arr;
	FILE *text_file;
	unsigned int i;
	unsigned int nspec = data->nspec;
	int rc;

	text_file = fdopen(fd, "w");
	if (!text_file) {
		perror("fopen output_file");
		exit(EXIT_FAILURE);
	}

	for (i = 0; i < nspec; i++) {
		char *regex = specs[i].regex_str;
		char *type = specs[i].type_str;
		char *context = specs[i].ctx_str;
		uint32_t to_write;

		rc = fprintf(text_file, "%s\t%s\t%s\n", regex, type, context);
		if (rc < 0) goto err;
	}

	rc = 0;

out:
	fclose(text_file);
	return rc;
err:
	rc = -1;
	goto out;
}

static void free_specs(struct saved_data2 *data)
{
	struct spec2 *specs = data->spec_arr;
	unsigned int num_entries = data->nspec;
	unsigned int i;

	for (i = 0; i < num_entries; i++) {
		free(specs[i].regex_str);
		free(specs[i].type_str);
		free(specs[i].ctx_str);
	}
	free(specs);

	num_entries = data->num_stems;
	for (i = 0; i < num_entries; i++) free(data->stem_arr[i].buf);
	free(data->stem_arr);

	memset(data, 0, sizeof(*data));
}

static void usage(const char *progname)
{
	fprintf(stderr,
			"usage: %s [-o out_file] [-s] fc_bin\n"
			"Where:\n\t"
			"-o     Optional file name of the text based file contexts\n\t"
			"       file to be output. If not specified the default will\n\t"
			"       be fc_bin without the .bin suffix. If the suffix is\n\t"
			"       missing the default will be fc_bin with a _fc suffix\n\t"
			"       appended.\n\t"
			"fc_bin The PCRE formatted binary file to be processed.\n",
			progname);
	exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
	const char *path = NULL;
	const char *out_file = NULL;
	char stack_path[PATH_MAX + 1];
	char *tmp = NULL;
	int fd, rc, opt;
	struct stat buf;
	struct saved_data2 *data;

	if (argc < 2) usage(argv[0]);

	while ((opt = getopt(argc, argv, "o:")) > 0) {
		switch (opt) {
			case 'o':
				out_file = optarg;
				break;
			default:
				usage(argv[0]);
		}
	}

	if (optind >= argc) usage(argv[0]);

	path = argv[optind];
	if (stat(path, &buf) < 0) {
		fprintf(stderr, "Can not stat: %s: %m\n", path);
		exit(EXIT_FAILURE);
	}

	data = (struct saved_data2 *)calloc(1, sizeof(*data));
	if (!data) {
		fprintf(stderr, "Failed to calloc saved_data2\n");
		exit(EXIT_FAILURE);
	}
	rc = read_binary_file(data, path);
	if (rc < 0) goto err;

	if (out_file)
		rc = snprintf(stack_path, sizeof(stack_path), "%s", out_file);
	else {
		int len = (int)strlen(path);
		if (len < 5 || strcmp(&path[len - 4], ".bin"))
			rc = snprintf(stack_path, sizeof(stack_path), "%s_fc", path);
		else
			rc = snprintf(stack_path, sizeof(stack_path), "%.*s", len - 4, path);
	}

	if (rc < 0 || rc >= (int)sizeof(stack_path)) goto err;

	tmp = malloc(strlen(stack_path) + 7);
	if (!tmp) goto err;

	rc = sprintf(tmp, "%sXXXXXX", stack_path);
	if (rc < 0) goto err;

	fd = mkstemp(tmp);
	if (fd < 0) goto err;

	rc = fchmod(fd, buf.st_mode);
	if (rc < 0) {
		perror("fchmod failed to set permission on compiled regexs");
		goto err_unlink;
	}

	rc = write_text_file(data, fd);
	if (rc < 0) goto err_unlink;

	rc = rename(tmp, stack_path);
	if (rc < 0) goto err_unlink;

	rc = 0;

out:
	free_specs(data);
	free(data);
	free(tmp);
	return rc;

err_unlink:
	unlink(tmp);
err:
	rc = -1;
	goto out;
}