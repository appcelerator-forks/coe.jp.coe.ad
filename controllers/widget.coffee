###*
###
args = arguments[0] || {}
$.adview.applyProperties args

makeAdmobView = (obj)->
  Admob = require("ti.admob")
  obj.publisherId ?= Alloy.CFG.publisherId
  Ti.API.debug "obj.publisherId #{obj.publisherId}"
  obj.kindAd = if Alloy.isTablet then 1 else 0
  admobview = Admob.createView obj
  admobview.addEventListener "didReceiveAd", (e) =>
    Ti.API.debug "didReceiveAd"
  admobview
makeAdmob = (obj,tmpadview)->
  Ti.API.debug "makeAdmob"
  $.adview.remove tmpadview
  admobview = makeAdmobView obj
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
    unless ENV_PRODUCTION then Ti.API.debug "nendエラー #{e}"
    Ti.API.debug "nendエラー #{e}"
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
  is_tablet =  Alloy.isTablet
  obj ?=
    #広告
    if is_tablet
      _.extend Alloy.CFG.tablet,Alloy.CFG.ad_tablet
    else
      _.extend Alloy.CFG.phone,Alloy.CFG.ad_phone

    #obj.width = $.adview.width
  $.adview.height = if Alloy.isTablet then 90 else 50 #obj.height
  $.adview.width = if Alloy.isTablet then 720 else 320 #obj.width
  return obj if Alloy.CFG.ad.hide
  # $.adview.bottom = obj.bottom if obj.bottom?
  # $.adview.top = obj.top if obj.top?
  #obj.width = $.adview.width
  adview = null
  
  #日本だったらnend AndroidでタブレットだったらAdmob
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
      adview = makeAdmobView obj
        
      $.adview.add adview
  obj