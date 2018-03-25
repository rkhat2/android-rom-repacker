#include <errno.h>
#include <stdio.h>
#include <string.h>

#include <sys/stat.h>

/* A file security context specification. */
struct spec2 {
	char *regex_str; /* regular expession string */
	char *type_str;  /* type string */
	char *ctx_str;   /* context string */
	int stem_id;	 /* indicates which stem-compression item */
};

/* A regular expression stem */
struct stem2 {
	char *buf;
	int len;
	unsigned int nspec; /* number of specs that use this stem */
};

/* Our stored configuration */
struct saved_data2 {
	/*
	 * The array of specifications, initially in the same order as in
	 * the specification file. Sorting occurs based on hasMetaChars.
	 */
	struct spec2 *spec_arr;
	unsigned int nspec;
	unsigned int alloc_specs;

	/*
	 * The array of regular expression stems.
	 */
	struct stem2 *stem_arr;
	int num_stems;
	int alloc_stems;
	unsigned int num_specs_no_stem; /* number of specs with no stem */
};

static inline int mode_to_string(mode_t mode, char **mode_str)
{
	*mode_str = NULL;
	char *tmp = NULL;
	int str_len;

	switch (mode) {
		case 0:
			tmp = "";
			str_len = 0;
			break;
		case S_IFBLK:
			tmp = "-b";
			str_len = 2;
			break;
		case S_IFCHR:
			tmp = "-c";
			str_len = 2;
			break;
		case S_IFDIR:
			tmp = "-d";
			str_len = 2;
			break;
		case S_IFIFO:
			tmp = "-p";
			str_len = 2;
			break;
		case S_IFLNK:
			tmp = "-l";
			str_len = 2;
			break;
		case S_IFSOCK:
			tmp = "-s";
			str_len = 2;
			break;
		case S_IFREG:
			tmp = "--";
			str_len = 2;
			break;
		default:
			return -1;
	}

	*mode_str = strndup(tmp, str_len);
	return 0;
}

static inline int initialze_stems2(struct saved_data2 *data, size_t total_stems)
{
	struct stem2 *stems;

	stems = malloc(total_stems * sizeof(*stems));
	if (!stems) {
		perror("malloc");
		return -1;
	}

	data->stem_arr = stems;
	data->alloc_stems = total_stems;
	data->num_stems = 0;
	data->num_specs_no_stem = 0;

	return 0;
}

static inline int initialize_specs2(struct saved_data2 *data, size_t total_specs)
{
	struct spec2 *specs;

	specs = malloc(total_specs * sizeof(*specs));
	if (!specs) {
		perror("malloc");
		return -1;
	}

	data->spec_arr = specs;
	data->alloc_specs = total_specs;
	data->nspec = 0;

	return 0;
}

/* returns the index of the new stored object */
static inline int store_stem2(struct saved_data2 *data, char *buf, int stem_len)
{
	int num = data->num_stems;

	if (num >= data->alloc_stems) return -1;

	data->stem_arr[num].len = stem_len;
	data->stem_arr[num].buf = buf;
	data->stem_arr[num].nspec = 0;
	data->num_stems++;

	return num;
}

/* returns the index of the new stored object */
static inline int store_spec2(struct saved_data2 *data, char *regex_str, char *ctx_str, mode_t mode,
							  int stem_id)
{
	int num = data->nspec;
	char *type_str;
	int rc;

	if (num >= data->alloc_specs) {
		return -1;
	}

	rc = mode_to_string(mode, &type_str);
	if (rc) {
		free(regex_str);
		free(ctx_str);
		return -1;
	}

	data->spec_arr[num].regex_str = regex_str;
	data->spec_arr[num].type_str = type_str;
	data->spec_arr[num].ctx_str = ctx_str;
	data->spec_arr[num].stem_id = stem_id;
	data->nspec++;

	if (stem_id >= data->num_stems) {
		free(regex_str);
		free(type_str);
		free(ctx_str);
		return -1;
	}

	if (stem_id < 0) {
		data->num_specs_no_stem++;
	} else {
		data->stem_arr[stem_id].nspec++;
	}

	return num;
}