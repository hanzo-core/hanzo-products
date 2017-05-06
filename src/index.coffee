import Daisho  from 'daisho'
import Promise from 'broken'
import moment  from 'moment-timezone'
import numeral from 'numeral'

import html from './templates/home.pug'
import css  from './css/app.styl'

rfc3339  =  Daisho.util.time.rfc3339
yyyymmdd =  Daisho.util.time.yyyymmdd

class HanzoOrders extends Daisho.Views.Dynamic
  tag: 'hanzo-orders'
  html: html
  css:  css

  init: ->
    super

HanzoOrders.register()

export default class Orders
  constructor: (daisho, ps, ms, cs)->
    tag = null

    ps.register 'orders',
      ->
        @el = el = document.createElement 'hanzo-orders'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ms.register 'Orders', ->
      ps.show 'orders'
