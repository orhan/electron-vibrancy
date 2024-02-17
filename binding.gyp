{
    "targets": [
        {
            "target_name": "Vibrancy",
            "sources": [],
            'conditions':[
                ['OS!="mac"', {
                    "sources!": [
                        "src/Common.h",
                        "src/Vibrancy.h",
                        "src/Vibrancy.mm",
                        "src/VibrancyHelper.h",
                        "src/Init.mm",
                        "src/vibrancy_mac.cc",
                        "src/vibrancy_mac.mm",
                    ]
                }],
                ['OS!="win"', {
                    "sources!": [
                        "src/Common.h",
                        "src/Vibrancy.h",
                        "src/Vibrancy.mm",
                        "src/VibrancyHelper.h",
                        "src/Init.mm",
                        "src/vibrancy_win.cc"
                    ]
                }],
                ['OS!="linux"', {
                    "sources!": [
                        "src/Common.h",
                        "src/Vibrancy.h",
                        "src/Vibrancy.mm",
                        "src/VibrancyHelper.h",
                        "src/Init.mm",
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
