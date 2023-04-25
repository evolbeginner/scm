#! /bin/env ruby


####################################################
require 'getoptlong'


####################################################
def translate_state(state_str)
  if $is_holo
    case state_str
      when /^A$/
        return('Symbiodinium_minutum,Paramecium_tetraurelia')
      when /^N$/
        return('Arabidopsis_thaliana,Homo_sapiens')
      when /^Z$/
        return('root')
    end
  elsif $is_tene
    case state_str
      when /^A$/
        return('Salpingoeca_rosetta,Homo_sapiens')
      when /^N$/
        return('Daphnia_pulex,Drosophila_melanogaster')
      when /^F$/
        return('Spizellomyces_punctatus,Ustilago_maydis')
      when /^Z$/
        return('root')
    end      
  else
    case state_str
      when /^A$/
        return('Salpingoeca_rosetta,Homo_sapiens')
      when /^N$/
        return('Arabidopsis_thaliana,Homo_sapiens')
      when /^F$/
        return('Spizellomyces_punctatus,Ustilago_maydis')
      when /^Z$/
        return('root')
    end
  end
end


def auto_detect_is_holo(infile)
  realpath = `realpath #{infile}`.chomp
  return (realpath =~ /Holo/ ? true : false)
end

def auto_detect_is_tene(infile)
  realpath = `realpath #{infile}`.chomp
  return (realpath =~ /Tene/ ? true : false)
end


####################################################
def convert_joint_prob(symbionts, line, in_fh)
<<EOF
  #node
  Candidatus_Berkiella_aquae-GCA_001431295.1|Coxiella_burnetii_str_Schperling-GCA_002634065.1 
  Coxiella_burnetii_str_Schperling-GCA_002634065.1|Coxiella-like_endosymbiont-GCA_002871095.1 

  #joint_prob
     A|A    N|A    Z|A 
  0.0019 0.9606 0.0375 
EOF
  puts symbionts.join("\t")
  state_strs = line.split(/\s+/).select{|i|i=~/\w/} # state_str: 'A|N'
  new_states = state_strs.map{|state_str| state_str.split('|').map{|i| translate_state(i) } }
  probs = in_fh.readline.chomp.split(/\s+/)
  state2prob = new_states.map{|i|i.join("\t")}.zip(probs)
  puts state2prob.map{|i|i.join("\t")}.join("\n")
end


def convert_marginal_prob(symbionts, line, in_fh)
<<EOF
#node
Candidatus_Berkiella_aquae-GCA_001431295.1|Coxiella_burnetii_str_Schperling-GCA_002634065.1 
Coxiella_burnetii_str_Schperling-GCA_002634065.1|Coxiella-like_endosymbiont-GCA_002871095.1 

#marginal_prob
          A      N      Z
[1,] 0.0019 0.9606 0.0375
[2,] 1.0000 0.0000 0.0000

[1]  1 10  1
null device 
EOF
  count = 0
  states = line.split(/\s+/).select{|i|i=~/\w/} # state_str: 'A'
  new_states = states.map{|state| translate_state(state) }

  while probs = in_fh.readline.chomp.split(/\s+/).delete_if{|i| i =~ /[^+0-9\.e-]/ } do
    return() if probs.empty?
    probs.map!{|prob| prob =~ /^0e[+]0+$/ ? 0 : prob}
    out_strs = Array.new
    out_strs << symbionts[count]
    state2prob = new_states.zip(probs)
    out_strs << state2prob.select{|a|a[0] != 'root'}.map{|a|a.join(':')}.join("\t")
    puts out_strs.join("\t")
    count += 1
  end

end


####################################################
infile = nil
is_joint = false
is_marginal = false
$is_holo = false
$is_tene = false


####################################################
opts = GetoptLong.new(
  ['-i', GetoptLong::REQUIRED_ARGUMENT],
  ['--joint', GetoptLong::NO_ARGUMENT],
  ['--marginal', GetoptLong::NO_ARGUMENT],
)

opts.each do |opt, value|
  case opt
    when '-i'
      infile = value
    when '--joint'
      is_joint = true
    when '--marginal'
      is_marginal = true
  end
end


####################################################
$is_holo = auto_detect_is_holo(infile)
$is_tene = auto_detect_is_tene(infile)


####################################################
in_fh = File.open(infile, 'r')
is_read_node, is_read_prob = [false] * 2
symbionts = Array.new
in_fh.each_line do |line|
  line.chomp!
  case line
    when /^#node/
      is_read_node = true
      next
    when /^#(joint|marginal)_prob/
      is_read_node = false
      is_read_prob = true
      next
  end

  next if line =~ /^$/

  if is_read_node
    symbionts << line.sub(/\s+$/, '').gsub('|', ',')
    next
  end

  if is_read_prob
    if is_joint
      convert_joint_prob(symbionts, line, in_fh)
    elsif is_marginal
      convert_marginal_prob(symbionts, line, in_fh)
      break
    end
  end
end
in_fh.close


