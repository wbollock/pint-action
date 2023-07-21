#!/bin/sh -l

if [ "$CONFIG" != "" ]; then
    CONFIG="--config=$CONFIG"
fi

if  [ "$LOGLEVEL" != "" ]; then
    LOGLEVEL="--log-level=$LOGLEVEL"
fi

if  [ "$MIN_SEVERITY" != "" ]; then
    MIN_SEVERITY="--min-severity=$MIN_SEVERITY"
fi

if  [ "$REQUIRE_OWNER" != "" ]; then
    REQUIRE_OWNER="--require-owner"
fi

if [ "$GITHUB_EVENT_NAME" != "pull_request" ]; then
    pint $CONFIG $LOGLEVEL lint $MIN_SEVERITY $REQUIRE_OWNER $WORKDIR
else
    CMD="ci"
    git config --global --add safe.directory ${GITHUB_WORKSPACE}
    BASEBRANCH="$GITHUB_BASE_REF"
    PRBRANCH="$GITHUB_HEAD_REF"

    if [ "${PULL_REQUEST_TARGET_REPO}" != "${PULL_REQUEST_SOURCE_REPO}" ]; then
    # pull request is from fork
        echo "Running steps for PR from fork"
        git config --global user.email "pint@fakemail.com"
        git config --global user.name "pint"
        git config pull.rebase false
        # # https://github.com/reg-viz/reg-suit#workaround-for-detached-head
        # # https://github.com/reg-viz/reg-suit/issues/590#issuecomment-1219155722
        # workaround for detached head
        git checkout ${GITHUB_HEAD_REF#refs/heads/} || git checkout -b ${GITHUB_HEAD_REF#refs/heads/}
        git branch --set-upstream-to=origin/master ${GITHUB_HEAD_REF}
        git pull

        # populate a local main branch with upstream data
        # TODO make master/main configurable
        git checkout remotes/origin/master
        git branch master
        git reset --hard remotes/origin/master
        git remote -v
        git pull origin master

        # go back to our fork branch
        git checkout ${GITHUB_HEAD_REF#refs/heads/}
        pint $CONFIG $LOGLEVEL $CMD --base-branch="master" $REQUIRE_OWNER
    else
    # pull request is not from fork


      echo ">>> BASE BRANCH: $BASEBRANCH"
      echo ">>> PR BRANCH: $PRBRANCH"

      echo ">>> GITHUB_WORKSPACE: $GITHUB_WORKSPACE"

      git fetch origin "$BASEBRANCH"
      git checkout "$BASEBRANCH"
      git fetch origin "$PRBRANCH"
      git checkout "$PRBRANCH"
      pint $CONFIG $LOGLEVEL $CMD --base-branch="$BASEBRANCH" $REQUIRE_OWNER
    fi


fi
