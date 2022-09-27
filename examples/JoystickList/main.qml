/*
 * Copyright (c) 2015-2016 Alex Spataru <alex_spataru@outlook.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0

ApplicationWindow {
    //
    // Holds the current joystick selected by the combobox
    //
    property int currentJoystick: 0

    //
    // Window geometry
    //
    minimumWidth: 400
    minimumHeight: 700

    //
    // Other window properties
    //
    visible: true
    title: qsTr ("QJoysticks Remote")

    //
    // Generates the axes, button and POV indicators when the user selects
    // another joystick from the combobox
    //
    function generateJoystickWidgets (id) {
        /* Clear the joystick indicators */
        axes.model = 0

        /* Change the current joystick id */
        currentJoystick = id

        /* Get current joystick information & generate indicators */
        if (QJoysticks.joystickExists (id)) {
            axes.model = QJoysticks.getNumAxes (id)
        }

        /* Resize window to minimum size */
        width = minimumWidth
        height = minimumHeight
    }

    //
    // Display all the widgets in a vertical layout
    //
    ColumnLayout {
        spacing: 5
        anchors.margins: 10
        anchors.fill: parent

        //
        // Joystick selector combobox
        //
        ComboBox {
            id: joysticks
            Layout.fillWidth: true
            model: QJoysticks.deviceNames
            onCurrentIndexChanged: generateJoystickWidgets (currentIndex)
            onCurrentTextChanged: generateJoystickWidgets (currentIndex)
        }

        RowLayout
        {
            Layout.fillWidth: true
            Text {
                color: "white"
                text: qsTr ("Host")
            }

            TextField {
                id: hostName
                Layout.fillWidth: true
                text: QJoysticks.hostName
                onEditingFinished: QJoysticks.hostName = text
            }

            Button {
                text: qsTr("Connect")
                enabled: true
                onClicked: QJoysticks.connectSocket ()
            }
        }

        //
        // Axes indicator
        //
        GroupBox {
            id: gb
            title: qsTr ("Axes")
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                spacing: -5
                anchors.left: parent.left
                anchors.right: parent.right
                Layout.fillWidth: true
                Layout.fillHeight: true

                //
                // Generate a progressbar for each joystick axis
                //
                Repeater {
                    id: axes
                    anchors.right: parent.right
                    Layout.fillWidth: true
                    delegate: ProgressBar
                    {
                        id: progressbar
                        minimumValue: -100
                        maximumValue: 100
                        anchors.right: parent.right
                        anchors.left: parent.left
                        Layout.topMargin: 20

                        value: 0
                        //Behavior on value {NumberAnimation{}}

                        Connections {
                            target: QJoysticks
                            function onAxisChanged(js,axis,value) {
                                if (currentJoystick === js && index === axis)
                                    progressbar.value = QJoysticks.getAxis (js, index) * 100
                            }
                        }
                    }
                }
            }
        }

        GroupBox {
            title: qsTr ("Switches")
            Layout.fillWidth: true
            Layout.fillHeight: true

            CheckBox {
                id: switch1
                text: "Switch 1"
                onClicked: QJoysticks.setSwitchState(0,checked)
            }
        }

        GroupBox {
            title: qsTr ("Log")
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextArea {
                objectName: "log"
                wrapMode: TextEdit.NoWrap
                anchors.topMargin: 20
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
            }
        }
    }
}
