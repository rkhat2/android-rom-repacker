# Lineage url
set(DEFAULT_LIBZ_URL "https://github.com/LineageOS/android_external_zlib.git")
# Lineage's PCRE not maintained. Using AOSP instead. 
set(DEFAULT_PCRE_URL "https://android.googlesource.com/platform/external/pcre")
set(DEFAULT_SELINUX_URL "https://github.com/LineageOS/android_external_selinux.git")
set(DEFAULT_CORE_URL "https://github.com/LineageOS/android_system_core.git")
# set(DEFAULT_EXTRAS_URL "https://github.com/LineageOS/android_system_extras.git")

# Lineage branches
set(DEFAULT_LIBZ_BRANCH "fb2bb3a981e9874abdde46b149d4a3c71aedbf47")
set(DEFAULT_PCRE_BRANCH ${DEFAULT_AOSP_BRANCH})
set(DEFAULT_SELINUX_BRANCH "cd407619c2eb83d871e82f6be2efab790230fedd")
set(DEFAULT_CORE_BRANCH "0fc19e981119afa5b591a6cdbac926ff3e6155df")
# set(DEFAULT_EXTRAS_BRANCH "a4c6bbd8cbf27b6b33aed46eb163a58299d094b5")

set(ANDROID_URL_HINT "Check https://github.com/LineageOS/android_system_core for more branches. 
    Use commit hashes. Otherwise changing branches will break")

# android_external_zlib
# 55411b151568e5e3ca27041a9e6bb65ba3469839        refs/heads/cm-13.0
# db8bc995325116d222cbbc3c376d5b200ba325e5        refs/heads/cm-14.1
# e9a4d7f00eabbcebf8395748d9c842196c84b683        refs/heads/lineage-15.1
# fb2bb3a981e9874abdde46b149d4a3c71aedbf47        refs/heads/lineage-16.0
# android_external_libselinux
# 943ed44a46ed95d557bf552b57fe61280a77489c        refs/heads/cm-13.0
# e9ed8de2f5866f12cfea4d7b1c61a91fbb710387        refs/heads/cm-14.1
# android_external_selinux
# d94fc1a7053db0df8670889b2396dce6e6e7317f        refs/heads/lineage-15.1
# cd407619c2eb83d871e82f6be2efab790230fedd        refs/heads/lineage-16.0
# android_system_core
# 4c26cb02061c4a4eae597cfdcea590350849cd2c        refs/heads/cm-13.0
# 50ec193312b1922df43fd1c8a609ac28e94c20c1        refs/heads/cm-14.1
# 61a084ecc39d02f6d609c5b69841896301ba68c1        refs/heads/lineage-15.1
# 0fc19e981119afa5b591a6cdbac926ff3e6155df        refs/heads/lineage-16.0
# android_system_extras
# 0d598afe878adff21637d2673a07a7280c7151c5        refs/heads/cm-13.0
# f30ae7fd7508bed7974045d37b70030e24c7d4e6        refs/heads/cm-14.1
# d28d5f025ffd573f00ded857248ec47f3c65274e        refs/heads/lineage-15.1
# a4c6bbd8cbf27b6b33aed46eb163a58299d094b5        refs/heads/lineage-16.0
