"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Vibrancy = require("bindings")("Vibrancy");
function AddView(buffer, options) {
    var viewOptions = {
        Material: options.material,
        Position: { x: options.x, y: options.y },
        Size: { width: options.width, height: options.height },
        ResizeMask: options.resizeMask,
        EffectState: options.effectState,
        MaskImagePath: options.maskImagePath,
        MaskImageInsets: options.maskImageInsets,
        CornerRadius: options.cornerRadius,
    };
    return Vibrancy.AddView(buffer, viewOptions);
}
function RemoveView(buffer, viewId) {
    return Vibrancy.RemoveView(buffer, viewId);
}
function UpdateView(buffer, viewId, options) {
    var viewOptions = {
        Material: options.material,
        Position: { x: options.x, y: options.y },
        Size: { width: options.width, height: options.height },
        ResizeMask: options.resizeMask,
        EffectState: options.effectState,
        MaskImagePath: options.maskImagePath,
        MaskImageInsets: options.maskImageInsets,
        CornerRadius: options.cornerRadius,
    };
    return Vibrancy.UpdateView(buffer, viewId, viewOptions);
}
function DisableVibrancy() {
    Vibrancy.DisableVibrancy();
}
var assignOptions = function (dimensions, effectOptions) {
    if (effectOptions.material === null ||
        typeof effectOptions.material === "undefined") {
        effectOptions.material = "appearance-based";
    }
    if (effectOptions.effectState === null ||
        typeof effectOptions.effectState === "undefined") {
        effectOptions.effectState = "follow-window";
    }
    var resizeMask = 2; //auto resize on both axis
    var viewOptions = {
        material: effectOptions.material,
        width: dimensions.width,
        height: dimensions.height,
        x: dimensions.x,
        y: dimensions.y,
        resizeMask: resizeMask,
        effectState: effectOptions.effectState,
        maskImagePath: effectOptions.maskImagePath,
        maskImageInsets: effectOptions.maskImageInsets,
        cornerRadius: effectOptions.cornerRadius,
    };
    return viewOptions;
};
var electronVibrancy = {
    setVibrancy: function (window, effectOptions) {
        if (window == null) {
            return -1;
        }
        var dimensions = {
            width: window.getSize()[0],
            height: window.getSize()[1],
            x: 0,
            y: 0,
        };
        var nativeOptions = assignOptions(dimensions, effectOptions);
        return AddView(window.getNativeWindowHandle(), nativeOptions);
    },
    addView: function (window, dimensions, effectOptions) {
        var nativeOptions = assignOptions(dimensions, effectOptions);
        return AddView(window.getNativeWindowHandle(), nativeOptions);
    },
    updateView: function (window, viewId, dimensions, effectOptions) {
        var nativeOptions = assignOptions(dimensions, effectOptions);
        return UpdateView(window.getNativeWindowHandle(), viewId, nativeOptions);
    },
    removeView: function (window, viewId) {
        return RemoveView(window.getNativeWindowHandle(), viewId);
    },
    disableVibrancy: function () {
        return DisableVibrancy();
    },
};
exports.default = electronVibrancy;
//# sourceMappingURL=index.js.map