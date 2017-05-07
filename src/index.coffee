import Daisho  from 'daisho'
import Promise from 'broken'
import moment  from 'moment-timezone'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import html1 from './templates/products.pug'
import html2 from './templates/product.pug'
import css  from './css/app.styl'

rfc3339  =  Daisho.util.time.rfc3339
yyyymmdd =  Daisho.util.time.yyyymmdd

class HanzoProducts extends Daisho.Views.Dynamic
  tag: 'hanzo-products'
  html: html1
  css:  css
  _dataStaleField: '{}'

  configs:
    'filter': []

  init: ->
    super

  _refresh: ->
    # filter = @data.get 'filter'
    @client.product.list().then (res)=>
      @data.set 'products', res.models
      @scheduleUpdate()

    return true

  show: (id, opts) ->
    return ()=>
      @services.page.show(id, opts)

HanzoProducts.register()

class HanzoProduct extends Daisho.Views.Dynamic
  tag: 'hanzo-product'
  html: html2
  css:  css
  configs:
    slug: [isRequired]
    name: [isRequired]
    sku:  [isRequired]
    description: null

  init: ->
    super

  _refresh: ()->
    @client.product.get(@data.get('id')).then (res)=>
      @data.set res
      @scheduleUpdate()

    return true


HanzoProduct.register()

export default class Products
  constructor: (daisho, ps, ms, cs)->
    tag = null
    opts = {}

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
      (ps, id)->
        opts.id = id if id?
        @el = el = document.createElement 'hanzo-product'

        tag = (daisho.mount el)[0]
        tag.data.set 'id', opts.id
        return el
      (ps, id)->
        opts.id = id if id?
        tag.data.set 'id', opts.id
        tag.refresh()
        return @el
      ->

    ms.register 'Products', ->
      ps.show 'products'
