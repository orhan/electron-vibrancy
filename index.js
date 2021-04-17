"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Vibrancy = require("bindings")("Vibrancy");
function AddView(buffer, options) {
    var viewOptions = {
        Material: options.material,
        Position: { x: options.x, y: options.y },
        Size: { width: options.width, height: options.height },
        ResizeMask: options.resizeMask,
        MaskImagePath: options.maskImagePath,
        EffectState: options.effectState,
    };
    return Vibrancy.AddView(buffer, viewOptions);
}
function RemoveView(buffer, viewId) {
    var viewOptions = { ViewId: viewId };
    return Vibrancy.RemoveView(buffer, viewOptions);
}
function UpdateView(buffer, options) {
    var viewOptions = {
        Material: options.material,
        Position: { x: options.x, y: options.y },
        Size: { width: options.width, height: options.height },
        ViewId: options.viewId,
        EffectState: options.effectState,
    };
    return Vibrancy.UpdateView(buffer, viewOptions);
}
function DisableVibrancy(buffer) {
    Vibrancy.SetVibrancy(false, buffer);
}
var electronVibrancy = {
    setVibrancy: function (window, options) {
        if (window == null) {
            return -1;
        }
        var width = window.getSize()[0];
        var height = window.getSize()[1];
        if (options.material === null || typeof options.material === "undefined") {
            options.material = "appearance-based";
        }
        if (options.effectState === null ||
            typeof options.effectState === "undefined") {
            options.effectState = "follow-window";
        }
        var resizeMask = 2; //auto resize on both axis
        var viewOptions = {
            material: options.material,
            width: width,
            height: height,
            x: 0,
            y: 0,
            resizeMask: resizeMask,
            maskImagePath: options.maskImagePath,
            effectState: options.effectState,
        };
        return AddView(window.getNativeWindowHandle(), viewOptions);
    },
    addView: function (window, options) {
        return AddView(window.getNativeWindowHandle(), options);
    },
    updateView: function (window, options) {
        return UpdateView(window.getNativeWindowHandle(), options);
    },
    removeView: function (window, viewId) {
        return RemoveView(window.getNativeWindowHandle(), viewId);
    },
    disableVibrancy: function (window) {
        return DisableVibrancy(window.getNativeWindowHandle());
    },
};
exports.default = electronVibrancy;
//# sourceMappingURL=index.js.map