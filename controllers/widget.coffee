###*
###
args = arguments[0] || {}
unless ENV_PRODUCTION then Ti.API.debug JSON.stringify args
$.adview.applyProperties args

makeAdmob = (obj,tmpadview)->
  $.adview.remove tmpadview
  Admob = require("ti.admob")
  obj.publisherId ?= Alloy.CFG.publisherId
  unless ENV_PRODUCTION then Ti.API.debug "obj.publisherId #{obj.publisherId}"
  admobview = Admob.createView obj
  admobview.addEventListener "didReceiveAd", (e) =>
    Ti.API.debug "didReceiveAd"
  $.adview.add admobview


createNend = (obj)->
  ad = require("net.nend")
  # adView = ad.createView obj
  if obj.nendId? then obj.apiKey = obj.nendId

  #TODO これだとエラーが起きる
  adView = ad.createView obj
  
  # 受信成功通知
  adView.addEventListener "receive", (e) ->
    Ti.API.info "nend receive"
  
  # 受信エラー通知
  adView.addEventListener "error", (e) ->
    Ti.API.error "nend error #{JSON.stringify e}"
    makeAdmob obj,adView
  # クリック通知
  adView.addEventListener "click", (e) ->
    Ti.API.info "nend click"
#   
  # btnLayout = Ti.UI.createView(layout: "horizontal")
#   
  # # 広告リロード停止ボタン
  # pauseBtn = Ti.UI.createButton(
    # title: "pause"
    # width: "50%"
  # )
  # pauseBtn.addEventListener "click", (e) ->
    # adView.pause()
#   
#   
  # # 広告リロード再開ボタン
  # resumeBtn = Ti.UI.createButton(
    # title: "resume"
    # width: "50%"
  # )
  # resumeBtn.addEventListener "click", (e) ->
    # adView.resume()
  adView

###*
@deplicate
###
isTablet = -> Alloy.isTablet
  #Ti.Platform.displayCaps.platformWidth >= 728 and Ti.Platform.displayCaps.platformHeight >= 728
exports.isTablet = isTablet
  
exports.setBottom = ->
  $.adview.bottom = 0
exports.setTop = ->
  $.adview.top = 0
exports.init = (obj,phonead=off)->
  is_tablet =  Alloy.isTablet #Ti.Platform.displayCaps.platformWidth >= Alloy.CFG.tablet.width and Ti.Platform.displayCaps.platformHeight >= Alloy.CFG.tablet.width #and !phonead
  obj ?=
    #広告
    if is_tablet
      _.extend Alloy.CFG.tablet,Alloy.CFG.ad_tablet
    else
      _.extend Alloy.CFG.phone,Alloy.CFG.ad_phone

    #obj.width = $.adview.width
  $.adview.height = obj.height
  $.adview.width = obj.width
  unless ENV_PRODUCTION then Ti.API.debug "2:#{JSON.stringify $.adview}"

  # $.adview.bottom = obj.bottom if obj.bottom?
  # $.adview.top = obj.top if obj.top?
  #obj.width = $.adview.width
  adview = null
  
  #日本だったらnend AndroidでタブレットだったらAdmob
  unless ENV_PRODUCTION then Ti.API.debug "おっけー！#{Titanium.Locale.getCurrentCountry()}"
  if Titanium.Locale.getCurrentCountry() is "JP" and !(OS_ANDROID and is_tablet)
    $.adview.add createNend obj
  else
    #iOSだったらiAdとadmob
    if Ti.UI.iOS?
      tmpadview = Ti.UI.iOS.createAdView
        zIndex: 1000
      # makeAdmob = ->
        # #$.adview.remove tmpadview
        # $.adview.remove tmpadview
        # Admob = require("ti.admob")
#       
        # admobview = Admob.createView obj
        # admobview.addEventListener "didReceiveAd", (e) =>
          # Ti.API.debug "didReceiveAd"
        # $.adview.add admobview
        
      tmpadview.addEventListener 'error', (e)=> 
        Ti.API.error "AdView error"
        makeAdmob(obj,tmpadview)

      tmpadview.addEventListener 'action', (e)=> 
        Ti.API.debug "action"
        makeAdmob(obj,tmpadview)
        
      $.adview.add tmpadview
      #makeAdmob()
    else if Ti.Android?
      Admob = require("ti.admob")
      # then create an adMob view
      obj.kindAd = if Alloy.isTablet then 1 else 0
        
      adview = Admob.createView obj
      #listener for adReceived
      adview.addEventListener Admob.AD_RECEIVED, ->
  
      #listener for adNotReceived
      adview.addEventListener Admob.AD_NOT_RECEIVED, ->
        
      $.adview.add adview
  obj