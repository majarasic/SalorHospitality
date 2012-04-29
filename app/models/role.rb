# coding: UTF-8
# BillGastro -- The innovative Point Of Sales Software for your Restaurant
# Copyright (C) 2011  Michael Franzl <michael@billgastro.com>
# 
# See license.txt for the license applying to all files within this software.
class Role < ActiveRecord::Base
  validates_presence_of :name
  serialize :permissions
  has_many :users
end
