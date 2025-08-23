const CPtr = Ptr{Nothing}

# flags 
# NFLOAT_ALLOW_UNDERFLOW does not slow vector processing
# flags NFLOAT_ALLOW_INF slows vector processing
# flags NFLOAT_ALLOW_NAN slows vector processing

const NFLOAT_ALLOW_UNDERFLOW = 0x01
const NFLOAT_ALLOW_INF       = 0x02
const NFLOAT_ALLOW_NAN       = 0x04

const NFLOAT_ALLOW_ALL       = 0x04 | 0x02 | 0x01
const NFLOAT_DISALLOW_NAN    = 0x02 | 0x01
const NFLOAT_DISALLOW_INF    = 0x04 | 0x01

const GR_CTX_STRUCT_DATA_BYTES = 6 * sizeof(UInt)

