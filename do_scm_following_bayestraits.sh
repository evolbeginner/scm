#! /bin/env bash


###########################################
RDQN=~/tools/self_bao_cun/phylo_mini/remove_duplicate_quote_nwk.sh

source ~/tools/self_bao_cun/packages/bash/util.sh

is_prepare=true
is_exclude_traits=false
is_outgrp=false
nsim=100
cpu=5
skip=900


###########################################
do_preparation(){
	cp ../traits.txt ./

	cat ../../../../../exclude.list > exclude.list
	if [ $is_exclude_traits == true ]; then
		[ -f ../../../../../exclude-traits.list ] && cat ../../../../../exclude-traits.list >> exclude.list
		ruby ~/tools/self_bao_cun/others/calculate_overlaps.rb --i1 traits.txt --i2 exclude.list --f1 1 --show 1 --content 1 | sponge traits.txt
	fi
	if [ "$is_outgrp" = false ]; then
		sed '/-$/!d' traits.txt | cut -f 1 >> exclude.list
	fi

	if [ $is_outgrp ]; then
		sed -i '/-$/d' traits.txt
	else
		awk '{if($2=="-"){$2="Z"}{print $1"\t"$2}}' traits.txt | sponge traits.txt
	fi

	if [ $is_outgrp ]; then
		# ufb_tree
		taxa=`head -1 ../../ufb.tre | nw_prune -f - exclude.list | nw_distance -n - | cut -f1` # included taxa
		nw_prune -v ../../ufb.tre $taxa | sponge ufb.tre
		binary=`is_remove_needed ufb.tre`
		if [ "$binary" == true ]; then
			nw_prune -v ufb.tre $taxa | $RDQN | sponge ufb.tre
		fi

		# rooted_tree
		taxa=`head -1 ../../rooted.tre | nw_prune -f - exclude.list | nw_distance -n - | cut -f1` # included taxa
		nw_prune -v ../../rooted.tre $taxa | sponge rooted.tre
		binary=`is_remove_needed rooted.tre`
		if [ "$binary" == true ]; then
			nw_prune -v rooted.tre $taxa | $RDQN | sponge rooted.tre
		fi
	fi
}


function is_remove_needed(){
	tree=$1
	leaf_no=`head -1 $tree | nw_stats - | grep leaves | awk '{print $2}'`
	quote_no=`head -1 $tree | sed 's/(/\n/g' | wc -l`
	if [ "$leaf_no" != "$quote_no" ]; then
		echo "true";
	else
		echo "false";
	fi
}


###########################################
while [ $# -gt 0 ]; do
	case $1 in
		--prepare)
			is_prepare=true
			;;
		--exclude_trait|--exclude_traits)
			is_exclude_traits=true
			;;
		--ml)
			methods=(${methods[@]} ml)
			;;
		--mcmc)
			methods=(${methods[@]} mcmc)
			;;
		--nsim)
			nsim=$2
			shift
			;;
		--cpu)
			cpu=$2
			shift
			;;
		--no_outgrp)
			is_outgrp=false
			;;
		--w_outgrp)
			is_outgrp=true
			;;
		--skip)
			skip=$2
			shift
			;;
		--outdir)
			outdir=$2
			shift
			;;
		--force)
			is_force=true
			;;
		*)
			echo "wrong param $2! Exiting ......" >&2
			exit 1
	esac
	shift
done


###########################################
mkdir_with_force $outdir $is_force

cd $outdir >/dev/null


###########################################
if [ "$is_prepare" == true ]; then
	do_preparation
fi

for method in ${methods[@]}; do
	echo $method
	#[ $method == 'mcmc' ] && nsim=500
	~/LHW-tools/scm/asr_by_scm.R -t ufb.tre --model ALL --nsim $nsim --state ./traits.txt --method $method --pic_type phylogram -o scm.trees-$method --cpu $cpu --skip $skip
	Rscript ~/LHW-tools/scm/plotMpState.R -t scm.trees-$method --ml_tree rooted.tre --skip 0 -o asr-$method.pdf --itol itol.pie.txt > plotMp.out
done

if [ $? == 0 ]; then
	echo -e "\nFinished!"
else
	echo -e "\nExiting with some error!"
fi


