import Daisho  from 'daisho'
import Promise from 'broken'
import moment  from 'moment-timezone'
import numeral from 'numeral'

import html1 from './templates/products.pug'
import html2 from './templates/product.pug'
import css  from './css/app.styl'

rfc3339  =  Daisho.util.time.rfc3339
yyyymmdd =  Daisho.util.time.yyyymmdd

class HanzoProducts extends Daisho.Views.Dynamic
  tag: 'hanzo-products'
  html: html1
  css:  css

  configs:
    'filter': []

  init: ->
    super

  _refresh: ->
    # filter = @data.get 'filter'
    @client.products.list(opts).then (res)=>
      @data.set 'products', res
      @scheduleUpdate()

    return true

HanzoProducts.register()

class HanzoProduct extends Daisho.Views.Dynamic
  tag: 'hanzo-product'
  html: html2
  css:  css

  init: ->
    super

HanzoProduct.register()

export default class Products
  constructor: (daisho, ps, ms, cs)->
    tag = null

    ps.register 'products',
      ->
        @el = el = document.createElement 'hanzo-products'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ps.register 'product',
      ->
        @el = el = document.createElement 'hanzo-product'

        tag = (daisho.mount el)[0]
        return el
      ->
        tag.refresh()
        return @el
      ->

    ms.register 'Products', ->
      ps.show 'products'
