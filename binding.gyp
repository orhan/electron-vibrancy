{
    "targets": [
        {
            "target_name": "Vibrancy",
            "sources": [
                "src/Common.h",
                "src/Vibrancy.h",
                "src/VibrancyHelper.h",
                "src/Init.cc",
                "src/Vibrancy.cc",
                "src/vibrancy_win.cc",
                "src/vibrancy_mac.mm",
                "src/vibrancy_linux.cc",
            ],
            'conditions':[
                ['OS!="mac"', {
                    "sources!": [
                        "src/vibrancy_mac.mm",
                    ]
                }],
                ['OS!="win"', {
                    "sources!": [
                        "src/vibrancy_win.cc"
                    ]
                }],
                ['OS!="linux"', {
                    "sources!": [
                        "src/vibrancy_linux.cc"
                    ]
                }]
            ],
            "link_settings": {
                "conditions":[
                    ['OS=="mac"', {
                        "libraries": [
                            'Foundation.framework',
                            'AppKit.framework',
                            'ScriptingBridge.framework'
                        ]
                    }],
                    ['OS=="win"', {
                        "libraries": [
                            'dwmapi.lib'
                        ]
                    }]
                ]
            },
            "xcode_settings": {
                "OTHER_CFLAGS": [
                    "-x objective-c++ -stdlib=libc++"
                ]
            },
            "variables":{
                "CURRENT_DIR":"<!(echo %~dp0)"
            },
            "include_dirs": [
                "<!(node -e \"require('nan')\")"
            ]
        }
    ]
}
