#!/usr/bin/env bash
echo "Cloning dependencies"
PBRP_MANIFEST=android-11.0
IMAGE=$(find $(pwd)/out/target/product/RMX3195/recovery.img 2>/dev/null)


# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
        -d sticker="CAACAgIAAxkBAAEDj8Fhx2p4bScwO1YFhXS7BphRfykHlwAC2hMAAjFFUErF3KBfiXHVSCME" \
        -d chat_id=$chat_id
}

function tmate() {
    tmate && tmate show-message \
    echo "Done"
}

function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• Zero Kernel •</b>%0ABuild started on <code>Git Pod.</code>%0AFor device <b>Realme C25/C25S </b> (Even) %0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>${KBUILD_COMPILER_STRING}</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b>#Stable"
}

function pbrp(){
    repo init --depth=1 -u git://github.com/PitchBlackRecoveryProject/manifest_pb.git -b ${PBRP_MANIFEST}
    repo sync -j$(nproc --all) --force-sync --no-tags --no-clone-bundle --prune --optimized-fetch
    echo "Source Synced Lets Put Device Source.."
    git clone https://github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME} -b ${CIRCLE_BRANCH} device/${VENDOR}/${DEVICE}
    export ALLOW_MISSING_DEPENDENCIES=true
    export LC_ALL=C
    source build/envsetup.sh
    lunch omni_${DEVICE}-eng
    mka recoveryimage -j$(nproc --all)

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    
}

function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

function push() {
    cd $(pwd)/out/target/product/RMX3195
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP,@$IMAGE "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Realme C25/C25S (EVEN)</b> | <b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}




sticker
sendinfo
#pbrp
#push
tmate
