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
    };
    return Vibrancy.UpdateView(buffer, viewOptions);
}
function DisableVibrancy(buffer) {
    Vibrancy.SetVibrancy(false, buffer);
}
var electronVibrancy = {
    setVibrancy: function (window, material, maskImagePath) {
        if (window == null) {
            return -1;
        }
        var width = window.getSize()[0];
        var height = window.getSize()[1];
        if (material === null || typeof material === "undefined") {
            material = 0;
        }
        var resizeMask = 2; //auto resize on both axis
        var viewOptions = {
            material: material,
            width: width,
            height: height,
            x: 0,
            y: 0,
            resizeMask: resizeMask,
            maskImagePath: maskImagePath,
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