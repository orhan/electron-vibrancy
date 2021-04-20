//----------------------------------------------------------------------------
// electron-vibrancy
// Copyright 2016 arkenthera
//
// MIT License
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice
// shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//----------------------------------------------------------------------------

#import <CoreServices/CoreServices.h>

#include "./VibrancyHelper.h"

namespace Vibrancy {
    bool IsHigherThanYosemite() {
        NSOperatingSystemVersion operatingSystemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
        return operatingSystemVersion.majorVersion == 10 && operatingSystemVersion.minorVersion > 10;
    }

    VibrancyHelper::VibrancyHelper() : viewIndex_(0) { }

    int32_t VibrancyHelper::AddView(unsigned char *buffer, v8::Local<v8::Array> options) {
        NSView *view = *reinterpret_cast<NSView **>(buffer);

        if (!view) {
            return -1;
        }

        int32_t viewId = -1;

        NSRect rect = [[view window] frame];

        ViewOptions viewOptions = GetOptions(options);

        if (viewOptions.Width <= 0 || viewOptions.Width > rect.size.width) {
            return viewId;
        }

        if (viewOptions.Height <= 0 || viewOptions.Height > rect.size.height) {
            return viewId;
        }

        if (viewOptions.X < 0) {
            return viewId;
        }
        
        if (viewOptions.Y < 0) {
            return viewId;
        }

        NSVisualEffectView *vibrantView =
            [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(viewOptions.X,
                                                                 viewOptions.Y,
                                                                 viewOptions.Width,
                                                                 viewOptions.Height)];

        [vibrantView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];

        if (viewOptions.ResizeMask == 0) {
            [vibrantView setAutoresizingMask:NSViewWidthSizable];
        }
        if (viewOptions.ResizeMask == 1) {
            [vibrantView setAutoresizingMask:NSViewHeightSizable];
        }
        if (viewOptions.ResizeMask == 2) {
            [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        }

        NSVisualEffectMaterial vibrancyType = GetVibrancyType(viewOptions.Material);
        [vibrantView setMaterial:vibrancyType];
        
        NSVisualEffectState effectState = GetEffectState(viewOptions.EffectState);
        [vibrantView setState:effectState];
        
        if (!viewOptions.MaskImagePath.empty()) {
            NSString *maskFile = [NSString stringWithCString:viewOptions.MaskImagePath.c_str() encoding:[NSString defaultCStringEncoding]];
            NSImage *image = [[NSImage alloc]initWithContentsOfFile:maskFile];
            [image setCapInsets:NSEdgeInsetsMake(viewOptions.MaskImageInsetTop, 
                                                viewOptions.MaskImageInsetLeft, 
                                                viewOptions.MaskImageInsetBottom, 
                                                viewOptions.MaskImageInsetRight)];
            [image setResizingMode:(NSImageResizingMode)NSImageResizingModeStretch];
            
            [vibrantView setMaskImage:image];
        }
        
        if (viewOptions.CornerRadius > 0.0) {
            [vibrantView setWantsLayer:true];
            [vibrantView.layer setCornerRadius:viewOptions.CornerRadius];
        }

        [view.window.contentView
            addSubview:vibrantView
            positioned:NSWindowBelow
            relativeTo:nil];

        viewId = viewIndex_;
        views_.insert(std::make_pair(viewId, vibrantView));
        viewIndex_++;
        return viewId;
    }

    bool VibrancyHelper::UpdateView(unsigned char *buffer, int viewId, v8::Local<v8::Array> options) {
        NSView *view = *reinterpret_cast<NSView **>(buffer);
        ViewOptions viewOptions = GetOptions(options);

        if (viewId == -1) {
            return false;
        }

        NSVisualEffectView *vibrantView = views_[viewId];

        if (!vibrantView) {
            return false;
        }

        NSRect frame = [view.window frame];

        if (viewOptions.Width == 0) {
            viewOptions.Width = frame.size.width;
        }
        if (viewOptions.Height == 0) {
            viewOptions.Height = frame.size.height;
        }

        if (viewOptions.Width <= 0 && viewOptions.Width < frame.size.width) {
            return false;
        }

        if (viewOptions.Height <= 0 && viewOptions.Height < frame.size.height) {
            return false;
        }

        if (viewOptions.X < 0) {
            return false;
        }
        if (viewOptions.Y < 0) {
            return false;
        }

        NSVisualEffectMaterial vibrancyType = GetVibrancyType(viewOptions.Material);
        [vibrantView setMaterial:vibrancyType];
        
        NSVisualEffectState effectState = GetEffectState(viewOptions.EffectState);
        [vibrantView setState:effectState];
        
        if (!viewOptions.MaskImagePath.empty()) {
            NSString *maskFile = [NSString stringWithCString:viewOptions.MaskImagePath.c_str() encoding:[NSString defaultCStringEncoding]];
            NSImage *image = [[NSImage alloc]initWithContentsOfFile:maskFile];
            [image setCapInsets:NSEdgeInsetsMake(viewOptions.MaskImageInsetTop, 
                                                viewOptions.MaskImageInsetLeft, 
                                                viewOptions.MaskImageInsetBottom, 
                                                viewOptions.MaskImageInsetRight)];
            [image setResizingMode:(NSImageResizingMode)NSImageResizingModeStretch];
            
            [vibrantView setMaskImage:image];
        }
        
        if (viewOptions.CornerRadius > 0.0) {
            [vibrantView setWantsLayer:true];
            [vibrantView.layer setCornerRadius:viewOptions.CornerRadius];
        }
        
        [vibrantView setFrame:NSMakeRect(viewOptions.X, viewOptions.Y, viewOptions.Width, viewOptions.Height)];                                
        return true;
    }

    bool VibrancyHelper::RemoveView(unsigned char *buffer, int viewId) {
        bool result = false;

        if (viewId == -1 || viewId > static_cast<int>(views_.size())) {
            return result;
        }

        std::map<int, NSVisualEffectView *>::iterator It = views_.find(viewId);

        if (It == views_.end()) {
            return false;
        }

        NSVisualEffectView *vibrantView = It->second;

        if (!vibrantView) {
            return result;
        }

        views_.erase(viewId);

        NSView *viewToRemove = vibrantView;
        [viewToRemove removeFromSuperview];

        return true;
    }
    
    NSVisualEffectMaterial VibrancyHelper::GetVibrancyType(std::string material) {
        NSVisualEffectMaterial vibrancyType = NSVisualEffectMaterialAppearanceBased;
        
        if (material == "appearance-based") {
            vibrancyType = NSVisualEffectMaterialAppearanceBased;
        } else if (material == "light") {
            vibrancyType = NSVisualEffectMaterialLight;
        } else if (material == "dark") {
            vibrancyType = NSVisualEffectMaterialDark;
        } else if (material == "titlebar") {
            vibrancyType = NSVisualEffectMaterialTitlebar;
        }

        if (@available(macOS 10.11, *)) {
            if (material == "selection") {
                vibrancyType = NSVisualEffectMaterialSelection;
            } else if (material == "menu") {
                vibrancyType = NSVisualEffectMaterialMenu;
            } else if (material == "popover") {
                vibrancyType = NSVisualEffectMaterialPopover;
            } else if (material == "sidebar") {
                vibrancyType = NSVisualEffectMaterialSidebar;
            } else if (material == "medium-light") {
                vibrancyType = NSVisualEffectMaterialMediumLight;
            } else if (material == "ultra-dark") {
                vibrancyType = NSVisualEffectMaterialUltraDark;
            }
        }
        
        if (@available(macOS 10.14, *)) {
            if (material == "header") {
                vibrancyType = NSVisualEffectMaterialHeaderView;
            } else if (material == "sheet") {
                vibrancyType = NSVisualEffectMaterialSheet;
            } else if (material == "window") {
                vibrancyType = NSVisualEffectMaterialWindowBackground;
            } else if (material == "hud") {
                vibrancyType = NSVisualEffectMaterialHUDWindow;
            } else if (material == "fullscreen-ui") {
                vibrancyType = NSVisualEffectMaterialFullScreenUI;
            } else if (material == "tooltip") {
                vibrancyType = NSVisualEffectMaterialToolTip;
            } else if (material == "content") {
                vibrancyType = NSVisualEffectMaterialContentBackground;
            } else if (material == "under-window") {
                vibrancyType = NSVisualEffectMaterialUnderWindowBackground;
            } else if (material == "under-page") {
                vibrancyType = NSVisualEffectMaterialUnderPageBackground;
            }
        }
        
        return vibrancyType;
    }

    NSVisualEffectState VibrancyHelper::GetEffectState(std::string effectState) {
        NSVisualEffectState visualEffectState = NSVisualEffectStateFollowsWindowActiveState;
        
        if (effectState == "follow-window") {
            visualEffectState = NSVisualEffectStateActive;
        } else if (effectState == "active") {
            visualEffectState = NSVisualEffectStateActive;
        } else if (effectState == "inactive") {
            visualEffectState = NSVisualEffectStateInactive;
        } 
        
        return visualEffectState;
    }

    VibrancyHelper::ViewOptions VibrancyHelper::GetOptions(v8::Local<v8::Array> options) {
        VibrancyHelper::ViewOptions viewOptions;
        viewOptions.ResizeMask = 2;
        viewOptions.Width = 0;
        viewOptions.Height = 0;
        viewOptions.X = 0;
        viewOptions.Y = 0;
        viewOptions.Material = "appearance-based";
        viewOptions.EffectState = "follow-window";
        viewOptions.MaskImagePath = "";
        viewOptions.MaskImageInsetTop = 0;
        viewOptions.MaskImageInsetLeft = 0;
        viewOptions.MaskImageInsetBottom = 0;
        viewOptions.MaskImageInsetRight = 0;
        viewOptions.CornerRadius = 0.0;

        V8Value vPosition = Nan::Get(options, Nan::New<v8::String>("Position").ToLocalChecked()).ToLocalChecked();
        V8Value vSize = Nan::Get(options, Nan::New<v8::String>("Size").ToLocalChecked()).ToLocalChecked();

        V8Value vAutoResizeMask = Nan::Get(options, Nan::New<v8::String>("ResizeMask").ToLocalChecked()).ToLocalChecked();
        V8Value vCornerRadius = Nan::Get(options, Nan::New<v8::String>("CornerRadius").ToLocalChecked()).ToLocalChecked();
        V8Value vMaterial = Nan::Get(options, Nan::New<v8::String>("Material").ToLocalChecked()).ToLocalChecked();
        V8Value vEffectState = Nan::Get(options, Nan::New<v8::String>("EffectState").ToLocalChecked()).ToLocalChecked();
        V8Value vMaskImagePath = Nan::Get(options, Nan::New<v8::String>("MaskImagePath").ToLocalChecked()).ToLocalChecked();
        V8Value vMaskImageInsets = Nan::Get(options, Nan::New<v8::String>("MaskImageInsets").ToLocalChecked()).ToLocalChecked();

        if (!vMaterial->IsNull() && vMaterial->IsString()) {
            v8::String::Utf8Value value(v8::Isolate::GetCurrent(), vMaterial->ToString(Nan::GetCurrentContext()).ToLocalChecked());
            viewOptions.Material = std::string(*value);
        }
        
        if (!vEffectState->IsNull() && vEffectState->IsString()) {
            v8::String::Utf8Value value(v8::Isolate::GetCurrent(), vEffectState->ToString(Nan::GetCurrentContext()).ToLocalChecked());
            viewOptions.EffectState = std::string(*value);
        }

        if (!vSize->IsUndefined() && !vSize->IsNull()) {
            V8Array vaSize = v8::Local<v8::Array>::Cast(vSize);

            V8Value vWidth = Nan::Get(vaSize, Nan::New<v8::String>("width").ToLocalChecked()).ToLocalChecked();
            V8Value vHeight = Nan::Get(vaSize, Nan::New<v8::String>("height").ToLocalChecked()).ToLocalChecked();

            if (!vWidth->IsNull() && vWidth->IsInt32()) {
                viewOptions.Width = vWidth->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }

            if (!vHeight->IsNull() && vHeight->IsInt32()) {
                viewOptions.Height = vHeight->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }
        }

        if (!vPosition->IsUndefined() && !vPosition->IsNull()) {
            V8Array vaPosition = v8::Local<v8::Array>::Cast(vPosition);

            V8Value vX = Nan::Get(vaPosition, Nan::New<v8::String>("x").ToLocalChecked()).ToLocalChecked();
            V8Value vY = Nan::Get(vaPosition, Nan::New<v8::String>("y").ToLocalChecked()).ToLocalChecked();

            if (!vX->IsNull() && vX->IsInt32()) {
                viewOptions.X = vX->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }

            if (!vY->IsNull() && vY->IsInt32()) {
                viewOptions.Y = vY->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }
        }

        if (!vAutoResizeMask->IsNull() && vAutoResizeMask->IsInt32()) {
            viewOptions.ResizeMask = vAutoResizeMask->Int32Value(Nan::GetCurrentContext()).ToChecked();
        }
        
        if (!vCornerRadius->IsNull() && vCornerRadius->IsInt32()) {
            viewOptions.CornerRadius = vCornerRadius->NumberValue(Nan::GetCurrentContext()).ToChecked();
        }
        
        if (!vMaskImagePath->IsNull() && vMaskImagePath->IsString()) {
            v8::String::Utf8Value value(v8::Isolate::GetCurrent(), vMaskImagePath->ToString(Nan::GetCurrentContext()).ToLocalChecked());
            viewOptions.MaskImagePath = std::string(*value);
        }
        
        if (!vMaskImageInsets->IsUndefined() && !vMaskImageInsets->IsNull()) {
            V8Array vaMaskImageInsets = v8::Local<v8::Array>::Cast(vMaskImageInsets);

            V8Value vTop = Nan::Get(vaMaskImageInsets, Nan::New<v8::String>("top").ToLocalChecked()).ToLocalChecked();
            V8Value vLeft = Nan::Get(vaMaskImageInsets, Nan::New<v8::String>("left").ToLocalChecked()).ToLocalChecked();
            V8Value vBottom = Nan::Get(vaMaskImageInsets, Nan::New<v8::String>("bottom").ToLocalChecked()).ToLocalChecked();
            V8Value vRight = Nan::Get(vaMaskImageInsets, Nan::New<v8::String>("right").ToLocalChecked()).ToLocalChecked();

            if (!vTop->IsNull() && vTop->IsInt32()) {
                viewOptions.MaskImageInsetTop = vTop->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }

            if (!vLeft->IsNull() && vLeft->IsInt32()) {
                viewOptions.MaskImageInsetLeft = vLeft->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }
            
            if (!vBottom->IsNull() && vBottom->IsInt32()) {
                viewOptions.MaskImageInsetBottom = vBottom->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }
            
            if (!vRight->IsNull() && vRight->IsInt32()) {
                viewOptions.MaskImageInsetRight = vRight->Int32Value(Nan::GetCurrentContext()).ToChecked();
            }
        }
        
        return viewOptions;
    }

    bool VibrancyHelper::DisableVibrancy() {
        if (views_.size() > 0) {
            for (size_t i = 0; i < views_.size(); ++i) {
                NSView *viewToRemove = views_[i];
                [viewToRemove removeFromSuperview];
            }

            views_.clear();
        }
        
        return true;
    }
} // namespace Vibrancy
