process sample_id_squeezemeta {
    
    input:
    val sample_tests
    val assemb_in
    val sample_squeezemeta

    output:
    file("test.samples")

    script:
    """
    
    bash ${sample_squeezemeta} ${assemb_in}
    Rscript ${sample_tests} ${assemb_in}
    ln -s ${assemb_in}/test.samples test.samples

    
    """
}

//chmod +x ${sample_squeezemeta}

//rm -f ${assemb_in}/testt.samples 
//rm -f ${assemb_in}/the.samples 
