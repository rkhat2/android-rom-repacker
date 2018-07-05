# Lineage url
set(DEFAULT_LIBZ_URL "https://github.com/LineageOS/android_external_zlib.git")
# Lineage's PCRE not maintained. Using AOSP instead. 
set(DEFAULT_PCRE_URL "https://android.googlesource.com/platform/external/pcre")
set(DEFAULT_LIBSELINUX_URL "https://github.com/LineageOS/android_external_libselinux.git")
set(DEFAULT_CORE_URL "https://github.com/LineageOS/android_system_core.git")
set(DEFAULT_EXTRAS_URL "https://github.com/LineageOS/android_system_extras.git")

# Lineage branches
set(DEFAULT_LIBZ_BRANCH "e1bc5b1518b01893550e754de4366fdae1c6f89d")
set(DEFAULT_PCRE_BRANCH ${DEFAULT_AOSP_BRANCH})
set(DEFAULT_LIBSELINUX_BRANCH "2e2f4ae0697745285fff29b89c031df8f2733e4f")
set(DEFAULT_CORE_BRANCH "5479772c09b945bef7ea75efce98c2be98f30258")
set(DEFAULT_EXTRAS_BRANCH "cba516a826f4bcdf9ce4038c40e3a9cc1c906700")

set(ANDROID_URL_HINT "Check https://github.com/LineageOS/android_system_core for more branches. 
    Use commit hashes. Otherwise changing branches will break")

# android_external_zlib
# e1bc5b1518b01893550e754de4366fdae1c6f89d        refs/heads/cm-12.1
# 55411b151568e5e3ca27041a9e6bb65ba3469839        refs/heads/cm-13.0
# db8bc995325116d222cbbc3c376d5b200ba325e5        refs/heads/cm-14.1
# e9a4d7f00eabbcebf8395748d9c842196c84b683        refs/heads/lineage-15.1
# android_external_libselinux
# 2e2f4ae0697745285fff29b89c031df8f2733e4f        refs/heads/cm-12.1
# 943ed44a46ed95d557bf552b57fe61280a77489c        refs/heads/cm-13.0
# e9ed8de2f5866f12cfea4d7b1c61a91fbb710387        refs/heads/cm-14.1
# android_system_core
# 5479772c09b945bef7ea75efce98c2be98f30258        refs/heads/cm-12.1
# 4c26cb02061c4a4eae597cfdcea590350849cd2c        refs/heads/cm-13.0
# 50ec193312b1922df43fd1c8a609ac28e94c20c1        refs/heads/cm-14.1
# 61a084ecc39d02f6d609c5b69841896301ba68c1        refs/heads/lineage-15.1
# android_system_extras
# cba516a826f4bcdf9ce4038c40e3a9cc1c906700        refs/heads/cm-12.1
# 0d598afe878adff21637d2673a07a7280c7151c5        refs/heads/cm-13.0
# f30ae7fd7508bed7974045d37b70030e24c7d4e6        refs/heads/cm-14.1
# d28d5f025ffd573f00ded857248ec47f3c65274e        refs/heads/lineage-15.1
