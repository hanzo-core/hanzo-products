import Daisho  from 'daisho'
import Promise from 'broken'
import moment  from 'moment-timezone'
import numeral from 'numeral'
import { isRequired } from 'daisho/src/views/middleware'

import html1 from './templates/products.pug'
import html2 from './templates/product.pug'
import css  from './css/app.styl'
# import TractorBeam from 'tractor-beam'

rfc3339  =  Daisho.util.time.rfc3339
yyyymmdd =  Daisho.util.time.yyyymmdd

class HanzoProducts extends Daisho.Views.Dynamic
  tag: 'hanzo-products'
  html: html1
  css:  css

  configs:
    'filter': []

  loading: false

  # table header configuration
  headers: [
    {
      name: 'Image'
      field: 'Slug'
      onclick: 'onheader'
    },
    {
      name: 'Name'
      field: 'Name'
      onclick: 'onheader'
    },
    {
      name: 'Slug'
      field: 'Slug'
      onclick: 'onheader'
    },
    {
      name: 'SKU'
      field: 'SKU'
      onclick: 'onheader'
    },
    {
      name: 'Price'
      field: 'Price'
      onclick: 'onheader'
    },
    {
      name: 'Created On'
      field: 'CreatedAt'
      onclick: 'onheader'
    },
    {
      name: 'Last Updated'
      field: 'UpdatedAt'
      onclick: 'onheader'
    }
  ]

  init: ->
    super

  # generate header onclick events
  onheader: (header)->
    ()=>
      if @data.get('sort') == header.field
        @data.set 'asc', !@data.get('asc')
      else
        @data.set 'asc', true
      @data.set 'sort', header.field
      @_refresh()

  create: ()->
    @services.page.show 'product', ''

  _refresh: ->
    #default sorting
    if !@data.get('sort')?
      @data.set 'sort', 'UpdatedAt'
      @data.set 'asc', false

    @loading = true
    @scheduleUpdate()

    # filter = @data.get 'filter'
    opts =
      sort: if @data.get('asc') then '-' + @data.get('sort') else @data.get('sort')
      display: 20
      page: 1

    @client.product.list(opts).then (res)=>
      @loading = false
      @data.set 'count', res.count
      @data.set 'products', res.models
      @scheduleUpdate()

  show: (id, opts) ->
    return ()=>
      @services.page.show id, opts

HanzoProducts.register()

class HanzoProduct extends Daisho.Views.Dynamic
  tag: 'hanzo-product'
  html: html2
  css:  css
  _dataStaleField:  'id'
  showResetModal: false
  showSaveModal: false
  loading: false

  dimensionsUnits:
    cm: 'cm'
    m:  'm'
    in: 'in'
    ft: 'ft'

  weightUnits:
    g:  'g'
    kg: 'kg'
    oz: 'oz'
    lb: 'lb'

  configs:
    slug:        [isRequired]
    name:        [isRequired]
    sku:         null
    price:       [isRequired]
    listPrice:   [isRequired]
    available:   null
    hidden:      null
    preorder:    null
    quantity:    null
    description: null

    'dimensions.length': null
    'dimensions.width':  null
    'dimensions.height': null
    dimensionsUnit:      null

    weight:            null
    weightUnit:        null
    estimatedDelivery: null

  init: ->
    super

    # @one 'updated', ()=>
    #   beam = new TractorBeam '.tractor-beam'
    #   beam.on 'dropped', (files) ->
    #     for filepath in files
    #       console.log 'Uploading...', filepath

  default: ()->
    # pull the org information from localstorage
    org = @daisho.akasha.get('orgs')[@daisho.akasha.get('activeOrg')]
    model =
      currency: org.currency

    return model

  _refresh: ()->
    id = @data.get('id')
    if !id
      @data.set @default()
      @scheduleUpdate()
      return true

    @loading = true
    @client.product.get(id).then (res)=>
      @showResetModal = false
      @loading = false
      @data.set res
      @scheduleUpdate()
    .catch (err)->
      @loading = false

    return true

  reset: ()->
    test = @_refresh()
    test

  save: ()->
    test = @submit()
    test

  showReset: ()->
    @showResetModal = true
    @scheduleUpdate()

  showSave: ()->
    @showSaveModal = true
    @scheduleUpdate()

  cancelModals: ()->
    @showResetModal = false
    @showSaveModal = false
    @scheduleUpdate()

  _submit: ()->
    @loading = true
    @client.product.update(@data.get()).then (res)=>
      @showSaveModal = false
      @loading = false
      @data.set res
      @scheduleUpdate()
    .catch (err)->
      @loading = false

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
