#!/bin/bash
# qqplot 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of datafile: '${datafile[@]}'"
    echo "Value of label: '$label'"
    echo "Value of p_col: '$p_col'"
    echo "Value of filter: '$filter'"
    echo "Value of use_gc_lambda: '$use_gc_lambda'"
    echo "Value of include_ci: '$include_ci'"
    echo "Value of qq_color: '${qq_color[@]}'"
    echo "Value of qq_color_criteria: '${qq_color_criteria[@]}'"
    echo "Value of output_type: '$output_type'"

    # Download input files and check in directory
    dx-download-all-inputs
    ls -sh in/datafile/*/*
    
    # Make directory for output files
    mkdir -p out/qqplots

    # Check filetype extension inside first folder of in/datafile
    if [[ "${#datafile[@]}" -lt "10" ]] ; then
    	z="0"
    else 
        z="00"
    fi
    file0=( in/datafile/$z/* )
    ext=${file0##*.}
    echo "File0: $file0, Ext: $ext"

    # If datafiles were tarred, untar them
    if [[ "$ext" == "tar" ]] ; then
        # tar xvf in/datafile/*/*tar
	# rm in/datafile/*/*tar
	echo "Tar files are not supported at this time. Supported filetypes: *Rda, *txt, *csv"
	exit
    fi

    wait

    if [[ "$ext" == "Rda" ]] ; then
        script="/qqplot_Rda.R"
    else
        script="/qqplot.R"
    fi

    seqmetaresults=( in/datafile/*/* )
    echo ${seqmetaresults[@]}

    # Remove spaces from color filtering criteria
    for ((i=0; i<${#qq_color_criteria[@]}; i++)) ; do
	if [[ "$i" == "0" ]] ; then
            qq_crit_trim="$( echo "${qq_color_criteria[$i]}" | sed 's/ //g' )"
        else
            qq_crit_trim="$qq_crit_trim $( echo "${qq_color_criteria[$i]}" | sed 's/ //g' )"
        fi
    done

    echo "Running Rscript... $script..."
    Rscript $script "$p_col;$filter;$use_gc_lambda;$include_ci;${qq_color[@]};$qq_crit_trim;$output_type;${seqmetaresults[@]}"

    # Upload results
    for f in *$output_type ; do
	mv $f ${label}_$f
    done
    qqplots=( *$output_type )
    mv "${qqplots[@]}" out/qqplots/
    echo "Checking out folder:"
    ls out/*
    
    echo "Uploading results..."
    dx-upload-all-outputs

}
