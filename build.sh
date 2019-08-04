#!/bin/bash
echo "build start"
mono SpeedyHtmlBuilder.exe index.shb
mono SpeedyHtmlBuilder.exe monogameTuts.shb
mono SpeedyHtmlBuilder.exe monogameTuts1.shb
mono SpeedyHtmlBuilder.exe advancedInput.shb
mono SpeedyHtmlBuilder.exe ControlsSource.shb
mono SpeedyHtmlBuilder.exe basic2dCamera.shb
mono SpeedyHtmlBuilder.exe 2dcameraSource.shb
mono SpeedyHtmlBuilder.exe contentdir.shb
mono SpeedyHtmlBuilder.exe contentutils.shb
mono SpeedyHtmlBuilder.exe textdrawing.shb
mono SpeedyHtmlBuilder.exe about.shb
echo "build complete"