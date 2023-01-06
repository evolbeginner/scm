#! /bin/env ruby


##########################################################
require 'getoptlong'
require 'bio-nwk'
require 'parallel'


##########################################################
treefile = nil
ml_treefile = nil
cpu = 4


##########################################################
opts = GetoptLong.new(
  ['-t', GetoptLong::REQUIRED_ARGUMENT],
  ['--ml_tree', GetoptLong::REQUIRED_ARGUMENT],
  ['--cpu', GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when '-t'
      treefile = value
    when '--ml_tree'
      ml_treefile = value
    when '--cpu'
      cpu = value.to_i
  end
end


##########################################################
mapped_tree = getTreeObjs(ml_treefile)[0]
eode2tips = 

trees = getTreeObjs(treefile)

trees.each do |tree|
  tree.each_node do |node|
    p tree.twoTaxaNode(node)
  end
  exit
end


