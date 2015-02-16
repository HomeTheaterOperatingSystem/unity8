/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Powerd 0.1

/*!
 \brief A mapper for the physical keys on the device

 A mapper to handle events triggered by pressing physical keys on a device.
 Keys included are
    * Volume Decrease
    * Volume Increase
    * Power

 This allows for handling the following events
    * Volume Decreases/Increases
    * Screenshots

*/

Item {
    id: root

    signal powerKeyLongPress();

    property bool screenshotPressed: d.volumeUpKeyPressed && d.volumeDownKeyPressed
    property bool volumeDownPressed: d.volumeDownKeyPressed && !d.volumeUpKeyPressed
    property bool volumeUpPressed: d.volumeUpKeyPressed && !d.volumeDownKeyPressed
    property int powerKeyLongPressTimeMs: 2000 // Is writable for testing purposes

    QtObject {
        id: d

        property bool volumeDownKeyPressed: false
        property bool volumeUpKeyPressed: false
    }

    // FIXME: event.isAutoRepeat is always false on Nexus 4.
    // So we use powerKeyTimer.running to avoid the PowerOff key repeat
    // https://launchpad.net/bugs/1349416
    Timer {
        id: powerKeyLongPressTimer

        interval: powerKeyLongPressTimeMs
        repeat: false
        triggeredOnStart: false
        onTriggered: powerKeyLongPress();
    }


    function onKeyPressed(key) {
        var eventAccepted = false;

        /* Determine what key was pressed */
        if (key == Qt.Key_PowerDown || key == Qt.Key_PowerOff) {

            // FIXME: We only consider power key presses if the screen is
            // on because of bugs 1410830/1409003.  The theory is that when
            // those bugs are encountered, there is a >2s delay between the
            // power press event and the power release event, which causes
            // the shutdown dialog to appear on resume.  So to avoid that
            // symptom while we investigate the root cause, we simply won't
            // initiate any dialogs when the screen is off.
            // This also prevents taking screenshots when the screen is off.
            if (Powerd.status === Powerd.On) {
                if (!powerKeyLongPressTimer.running) {
                    powerKeyLongPressTimer.restart();
                }
                eventAccepted = true;
            }
        } else if (key == Qt.Key_MediaTogglePlayPause || key == Qt.Key_MediaPlay) {
            eventAccepted = callManager.handleMediaKey(false);
        } else if (key == Qt.Key_VolumeDown) {
            d.volumeDownKeyPressed = true;
        } else if (key == Qt.Key_VolumeUp) {
            d.volumeUpKeyPressed = true;
        }

        return eventAccepted;
    }

    function onKeyReleased(key) {
        var eventAccepted = false;

        if (key == Qt.Key_PowerDown || key == Qt.Key_PowerOff) {
            powerKeyLongPressTimer.stop();
            eventAccepted = true;
        } else if (key == Qt.Key_VolumeDown) {
            d.volumeDownKeyPressed = false;
        } else if (key == Qt.Key_VolumeUp) {
            d.volumeUpKeyPressed = false;
        }

        return eventAccepted;
    }
}
