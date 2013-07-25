/*
 * Copyright (C) 2013 Canonical, Ltd.
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
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../../Components"

Column {
    id: root

    property var model

    signal sendReview(string review)

    spacing: units.gu(2)
    state: ""

    states: [
        State {
            name: ""
            PropertyChanges { target: sendButton; opacity: 0; }
            PropertyChanges { target: reviewField; width: root.width; }
        },
        State {
            name: "editing"
            PropertyChanges { target: reviewField; width: (root.width - row.spacing - sendButton.width); }
            PropertyChanges { target: sendButton; opacity: 1; }
        }
     ]

    transitions: [
        Transition {
            from: ""
            to: "editing"
            SequentialAnimation {
                UbuntuNumberAnimation { target: reviewField; properties: "width"; duration: UbuntuAnimation.SlowDuration }
                UbuntuNumberAnimation { target: sendButton; properties: "opacity"; duration: UbuntuAnimation.SlowDuration }
            }
        },
        Transition {
            from: "editing"
            to: ""
            SequentialAnimation {
                UbuntuNumberAnimation { target: sendButton; properties: "opacity"; duration: UbuntuAnimation.SlowDuration }
                UbuntuNumberAnimation { target: reviewField; properties: "width"; duration: UbuntuAnimation.SlowDuration }
            }
        }
    ]

    Label {
        fontSize: "medium"
        color: "white"
        style: Text.Raised
        styleColor: "black"
        opacity: .9
        text: i18n.tr("Add a review")
    }

    Row {
        id: row
        spacing: units.gu(1)
        width: root.width

        TextArea {
            id: reviewField
            objectName: "reviewField"
            placeholderText: i18n.tr("Review")
            width: parent.width
            verticalAlignment: Text.AlignVCenter
            autoSize: true
            maximumLineCount: 5

            Behavior on height { UbuntuNumberAnimation { duration: UbuntuAnimation.SnapDuration } }

            onFocusChanged: {
                if(reviewField.focus){
                    root.state = "editing";
                    reviewField.selectAll();
                }
            }

            InverseMouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: {
                    reviewField.focus = false;
                    root.state = "";
                }
            }
        }

        Button {
            id: sendButton
            objectName: "sendButton"
            width: units.gu(10)
            height: units.gu(4)
            anchors.bottom: reviewField.bottom
            color: Theme.palette.selected.foreground
            text: i18n.tr("Send")
            opacity: 0

            onClicked: {
                root.sendReview(reviewField.text);
                reviewField.text = ""
            }
        }
    }

    ListItem.ThinDivider {}

    Label {
        fontSize: "medium"
        color: "white"
        style: Text.Raised
        styleColor: "black"
        opacity: .9
        text: i18n.tr("Comments:")
    }

    Repeater {
        objectName: "commentsArea"
        model: root.model

        Column {
            width: parent.width

            Column {

                Label {
                    text: modelData.username
                    fontSize: "medium"
                    color: "white"
                    opacity: .8
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    wrapMode: Text.WordWrap
                    style: Text.Raised
                    styleColor: "black"
                }

                Row {
                    spacing: units.gu(1)

                    RatingStars {
                        maximumRating: 10
                        rating: modelData.rate
                    }

                    Label {
                        text: modelData.date
                        fontSize: "medium"
                        color: Theme.palette.selected.backgroundText
                        opacity: .6
                        style: Text.Raised
                        styleColor: "black"
                    }
                }
            }

            Label {
                text: modelData.comment
                fontSize: "medium"
                color: Theme.palette.selected.backgroundText
                opacity: .6
                anchors {
                    left: parent.left
                    right: parent.right
                }
                wrapMode: Text.WordWrap
                style: Text.Raised
                styleColor: "black"
            }
        }
    }
}
