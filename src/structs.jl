
# underlying structs
# https://github.com/kalmarek/Arblib.jl/pull/202

mutable struct nfloat_ctx_struct{Precision, Flags}
    data::NTuple{GR_CTX_STRUCT_DATA_BYTES, UInt8}
    which_ring::UInt
    sizeof_elem::Int
    methods::Ptr{Cvoid}
    size_limit::UInt

    function nfloat_ctx_struct{Precision::Int, Flags::Int}() where {Precision, Flags}
        ctx = new{Precision, Flags}()
        ret = init!(ctx, 64Precision, Flags)
        iszero(ret) || throw(DomainError(P, "cannot set precision to this value"))
        return ctx
    end
end

mutable struct nfloat_struct{Precision, Flags}
    head::NTuple{NFLOAT_HEADER_LIMBS,UInt}
    d::NTuple{Precision, UInt}

    function nfloat_struct{Precision::Int, Flags::Int}() where {Precision, Flags}
        res = new{Precision, Flags}()
        init!(res, nfloat_ctx_struct{Precision, Flags}())
        return res
    end
end

struct NFloat{Precision, Flags} <: AbstractFloat
    nfloat::nfloat_struct{Precision, Flags}

    NFloat{Precision, Flags}() where {Precision, Flags} = new{Precision, Flags}(nfloat_struct{Precision, Flags}())
end

struct NFloatRef{Precision, Flags} <: AbstractFloat
    nfloat_ptr::Ptr{nfloat_struct{Precision, Flags}}
    parent::Union{Nothing}
end

#???
macro def_nfloat_struct(bits)
    nb = bits ÷ FLINT_BITS
    T  = Symbol("NFLOAT", bits)
    quote
        struct $T <: Real
            head::NTuple{2, Culong}
            d::NTuple{$nb, Culong}
        end
    end
end

@eval begin
    $(@def_nfloat_struct(64))
    $(@def_nfloat_struct(128))
    $(@def_nfloat_struct(192))
    $(@def_nfloat_struct(256))
    $(@def_nfloat_struct(384))
    $(@def_nfloat_struct(512))
    $(@def_nfloat_struct(768))
    $(@def_nfloat_struct(1024))
    $(@def_nfloat_struct(2048))
    $(@def_nfloat_struct(4096))
end

# Shorthands
const NFloat64   = NFLOAT64
const NFloat128  = NFLOAT128
const NFloat192  = NFLOAT192
const NFloat256  = NFLOAT256
const NFloat384  = NFLOAT384
const NFloat512  = NFLOAT512
const NFloat768  = NFLOAT768
const NFloat1024 = NFLOAT1024
const NFloat2048 = NFLOAT2048
const NFloat4096 = NFLOAT4096

