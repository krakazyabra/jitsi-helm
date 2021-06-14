
config.constraints = {
    video: {
        height: {
            ideal: 480,
            max: 480,
            min: 240
        },
        width: {
            ideal: 854,
            max: 854,
            min: 320
        }
    }
}

// should reduce the load both server and client side for very little drawback
// (you can't get high quality streams of non speaker anymore)
// https://webrtchacks.com/suspending-simulcast-streams/
config.enableLayerSuspension = true

config.fileRecordingsEnabled = false
config.liveStreamingEnabled = false
config.transcribingEnabled = false

config.disableInviteFunctions = true

config.enableLipSync = false

config.toolbarButtons = [
    'microphone', 'camera', 'desktop', 'fullscreen',
    'fodeviceselection', 'hangup', 'profile', 'recording',
    'livestreaming', 'etherpad', 'sharedvideo', 'settings', 'raisehand',
    'videoquality', 'filmstrip', 'invite', 'feedback', 'stats', 'shortcuts',
    'tileview', 'select-background', 'download', 'help', 'mute-everyone', 'mute-video-everyone', 'security'
]

config.notifications = [
    'connection.CONNFAIL', // shown when the connection fails,
    'dialog.cameraNotSendingData', // shown when there's no feed from user's camera
    'dialog.kickTitle', // shown when user has been kicked
    'dialog.liveStreaming', // livestreaming notifications (pending, on, off, limits)
    'dialog.lockTitle', // shown when setting conference password fails
    'dialog.maxUsersLimitReached', // shown when maximmum users limit has been reached
    'dialog.micNotSendingData', // shown when user's mic is not sending any audio
    'dialog.passwordNotSupportedTitle', // shown when setting conference password fails due to password format
    'dialog.recording', // recording notifications (pending, on, off, limits)
    'dialog.remoteControlTitle', // remote control notifications (allowed, denied, start, stop, error)
    'dialog.reservationError',
    'dialog.serviceUnavailable', // shown when server is not reachable
    'dialog.sessTerminated', // shown when there is a failed conference session
    'dialog.tokenAuthFailed', // show when an invalid jwt is used
    'dialog.transcribing', // transcribing notifications (pending, off)
    'dialOut.statusMessage', // shown when dial out status is updated.
    'liveStreaming.busy', // shown when livestreaming service is busy
    'liveStreaming.failedToStart', // shown when livestreaming fails to start
    'liveStreaming.unavailableTitle', // shown when livestreaming service is not reachable
    'lobby.joinRejectedMessage', // shown when while in a lobby, user's request to join is rejected
    'lobby.notificationTitle', // shown when lobby is toggled and when join requests are allowed / denied
    'localRecording.localRecording', // shown when a local recording is started
    // Notifications for users connecting come in 1/2/3+ forms like the invites,
    // but 'notify.connectedOneMember'. They don't appear in the example config
    // but we don't want them.
    //'notify.disconnected', // shown when a participant has left
    'notify.grantedTo', // shown when moderator rights were granted to a participant
    'notify.invitedOneMember', // shown when 1 participant has been invited
    'notify.invitedThreePlusMembers', // shown when 3+ participants have been invited
    'notify.invitedTwoMembers', // shown when 2 participants have been invited
    'notify.kickParticipant', // shown when a participant is kicked
    'notify.mutedRemotelyTitle', // shown when user is muted by a remote party
    'notify.mutedTitle', // shown when user has been muted upon joining,
    'notify.newDeviceAudioTitle', // prompts the user to use a newly detected audio device
    'notify.newDeviceCameraTitle', // prompts the user to use a newly detected camera
    'notify.passwordRemovedRemotely', // shown when a password has been removed remotely
    'notify.passwordSetRemotely', // shown when a password has been set remotely
    'notify.raisedHand', // shown when a partcipant used raise hand,
    'notify.startSilentTitle', // shown when user joined with no audio
    'prejoin.errorDialOut',
    'prejoin.errorDialOutDisconnected',
    'prejoin.errorDialOutFailed',
    'prejoin.errorDialOutStatus',
    'prejoin.errorStatusCode',
    'prejoin.errorValidation',
    'recording.busy', // shown when recording service is busy
    'recording.failedToStart', // shown when recording fails to start
    'recording.unavailableTitle', // shown when recording service is not reachable
    'toolbar.noAudioSignalTitle', // shown when a broken mic is detected
    'toolbar.noisyAudioInputTitle', // shown when noise is detected for the current microphone
    'toolbar.talkWhileMutedPopup', // shown when user tries to speak while muted
    'transcribing.failedToStart' // shown when transcribing fails to start
]

// inject CSS to hide the chevron when the rest of the UI chrome is hidden
// (it sits there all the time which is particularly noticeable on jibri
// recordings / streams).
// This file is just parsed as javascript so is a convenient way to inject
// stuff like this (if somewhat evil). However, the jitsi meet react SDK
// parses it using node, so it must be node-compatible (ie. check for
// presence of 'document' and, with current versions, no template strings).
if (typeof(document) !== 'undefined') {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(
        "/* Hide filmstrip chevron */" +
        ".hide-videos .filmstrip__toolbar {" +
        "    display: none;" +
        "}" +

        "/* Dial down the insanely long animations */" +
        ".vertical-filmstrip .filmstrip .filmstrip__videos#remoteVideos {" +
        "    transition: right 0.4s ease;" +
        "}" +

        ".vertical-filmstrip .large-video-labels {" +
        "    transition: 0.4s ease !important;" +
        "}"
    ));

    document.head.appendChild(style);
}
