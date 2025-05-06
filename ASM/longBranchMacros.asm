#importonce

//bne
.macro jne(JumpToAddr)
{
    beq !ByPass+
    jmp JumpToAddr
!ByPass:
}
//beq
.macro jeq(JumpToAddr)
{
    bne !ByPass+
    jmp JumpToAddr
!ByPass:
}
//bcs
.macro jcs(JumpToAddr)
{
    bcc !ByPass+
    jmp JumpToAddr
!ByPass:
}
//bcc
.macro jcc(JumpToAddr)
{
    bcs !ByPass+
    jmp JumpToAddr
!ByPass:
}
//bvs
.macro jvs(JumpToAddr)
{
    bvc !ByPass+
    jmp JumpToAddr
!ByPass:
}
//bvc
.macro jvc(JumpToAddr)
{
    bvs !ByPass+
    jmp JumpToAddr
!ByPass:
}
//bmi
.macro jmi(JumpToAddr)
{
    bpl !ByPass+
    jmp JumpToAddr
!ByPass:
}
//bpl
.macro jpl(JumpToAddr)
{
    bmi !ByPass+
    jmp JumpToAddr
!ByPass:
}