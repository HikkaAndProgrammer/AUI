# AUI - Almiri User Interface

## Usage:

```lua
local AUI = require"AUI"


local UI = AUI.Layout{} -- create a base layout

function love.draw()
	UI:draw() -- draw layout
end
```

After you `require` the AUI module it can be referenced with `love.AUI` alias.

## Modules\Views:

+ AUI.Layout - simple layout to insert UI elements
+ AUI.TabLayout - layout that is able to change its inner elements
+ AUI.Button - simple button
+ AUI.ImageView - an UI element to show pictures
+ AUI.ParticleSystem - an AUI adapter for love's particle system
+ AUI.SelectView - an UI element to select from a set of variants
+ AUI.TextInput - element for text input
+ AUI.TextLabel - element that can display some text
+ AUI.UIObject - base UI object, parent for every UI object
+ AUI.Theme - module to require and set themes (for colorizing application)
+ AUI.Settings - module for saving/loading settings
+ AUI.Scaler - thing to make moving, scaling, etc objects properly
+ date - date data format encoder/decoder