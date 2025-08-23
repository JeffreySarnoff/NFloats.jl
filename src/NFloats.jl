module NFloats

using Libdl
using FLINT_jll

include("constants.jl")
include("libflint.jl")

# underlying structs
# https://github.com/kalmarek/Arblib.jl/pull/202

const GR_CTX_STRUCT_DATA_BYTES = 6 * sizeof(UInt)
mutable struct nfloat_ctx_struct{P,F}
    data::NTuple{GR_CTX_STRUCT_DATA_BYTES, UInt8}
    which_ring::UInt
    sizeof_elem::Int
    methods::Ptr{Cvoid}
    size_limit::UInt

    function nfloat_ctx_struct{P, F}() where {P, F}
        @assert P isa Int && F isa Int
        ctx = new{P,F}()
        ret = init!(ctx, 64P, F)
        iszero(ret) || throw(DomainError(P, "cannot set precision to this value"))
        return ctx
    end
end

const NFLOAT_HEADER_LIMBS = 2
mutable struct nfloat_struct{P,F}
    head::NTuple{NFLOAT_HEADER_LIMBS,UInt}
    d::NTuple{P,UInt} # FIXME: Should be different for 32 bit systems

    function nfloat_struct{P,F}() where {P,F}
        @assert P isa Int && F isa Int
        res = new{P,F}()
        init!(res, nfloat_ctx_struct{P,F}())
        return res
    end
end

# or

# gr_ctx_struct (public header). We mirror it by value.
const GR_CTX_STRUCT_DATA_BYTES = 6*sizeof(Culong)

struct GRDataBlob
    bytes::NTuple{GR_CTX_STRUCT_DATA_BYTES, UInt8}
end

struct GrCtxStruct
    data::GRDataBlob
    which_ring::Culong
    sizeof_elem::Clong
    methods::Ptr{Cvoid}
    size_limit::Culong
end

mutable struct GrCtx
    ctx::GrCtxStruct
end

@inline _ctxref(g::GrCtx) = Ref(g.ctx)

# nfloat{BITS}_struct: head[2] + d[bits/64] (public header pattern)
# (If your FLINT build changes this, adjust below accordingly.)
const FLINT_BITS = 64

@generated function _nlimbs(::Val{B}) where {B}
    n = Int(B) ÷ FLINT_BITS
    :(Val{$n}())
end
  
macro def_nfloat_struct(bits)
    nb = bits ÷ FLINT_BITS
    T  = Symbol("NFloat", bits, "Struct")
    quote
        struct $T
            head::NTuple{2, Culong}
            d::NTuple{$nb, Culong}
        end
    end
end

end  # NFloats
