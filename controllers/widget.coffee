###*
@requires ti.admob
@requires net.nend
###
args = arguments[0] || {}
$.adview.applyProperties args

TAG = "jp.coe.ad "


makeAdmobView = (obj)->
  console.log "#{TAG} makeAdmobView"
  Admob = require("ti.admob")
  obj.adUnitId ?= Alloy.CFG.publisherId
  Ti.API.debug "obj.publisherId #{obj.adUnitId}"
  # obj.testDevices = [Admob.SIMULATOR_ID]
  console.debug "#{TAG} "+JSON.stringify obj 
  ad = Admob.createView obj
  ad.addEventListener 'didReceiveAd', ->
    console.debug 'Did receive ad!'
    return
  ad.addEventListener 'didFailToReceiveAd', ->
    console.debug 'Failed to receive ad!'
    return
  ad.addEventListener 'willPresentScreen', ->
    console.debug 'Presenting screen!'
    return
  ad.addEventListener 'willDismissScreen', ->
    console.debug 'Dismissing screen!'
    return
  ad.addEventListener 'didDismissScreen', ->
    console.debug 'Dismissed screen!'
    return
  ad.addEventListener 'willLeaveApplication', ->
    console.debug 'Leaving the app!'
    return
  ad
makeAdmob = (obj,tmpadview)->
  console.log "#{TAG} makeAdmob"
  $.adview.remove tmpadview if tmpadview?
  admobview = makeAdmobView obj
  $.adview.add admobview



createNend = (obj)->
  console.log "#{TAG} createNend"
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
exports.init = (obj,isAd=on)->
  console.log "#{TAG} init"
  is_tablet =  Alloy.isTablet
  obj ?=
    #広告
    if is_tablet
      _.extend Alloy.CFG.tablet,Alloy.CFG.ad_tablet
    else
      _.extend Alloy.CFG.phone,Alloy.CFG.ad_phone

    #obj.width = $.adview.width]
  # unless isAd
  #   $.adview.height = 0 
  #   $.adview.width = 0 
  #   return obj 
  $.adview.height = if Alloy.isTablet then 90 else 50 #obj.height
  $.adview.width = if Alloy.isTablet then 720 else 320 #obj.width
  # $.adview.bottom = obj.bottom if obj.bottom?
  # $.adview.top = obj.top if obj.top?
  #obj.width = $.adview.width
  adview = null

  #iOSだったらiAdとadmob
  if Ti.UI.iOS?
    tmpadview = Ti.UI.iOS.createAdView
      zIndex: 1000
      
    tmpadview.addEventListener 'error', (e)-> 
      Ti.API.error "AdView error"
      makeAdmob(obj,tmpadview)

    $.adview.add tmpadview
  else if Ti.Android?
    adview = makeAdmobView obj
      
    $.adview.add adview
  obj