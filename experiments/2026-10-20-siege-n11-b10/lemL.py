# Rigorous (outward-rounded) branch-and-bound check of Lemma L(e) for e in [0, 0.3684].
# For each e-interval [ea,eb] with parameters (lam,k,j) it proves
#   F(e,r,s) = lam*I + (1-lam)*Theta(r) < pi/10
# on {(e,r,s): ea<=e<=eb, r0-1<=r<=3-e, |r-s|<=e}, where
#   I = phi - k*sin(phi)*cos(psi) + (j/2)*sin(2phi)*cos(2psi), phi=acos(min(s,2)/2),
#   cos(psi) = (r^2-s^2-e^2)/(2es) (clamped to [-1,1]),
#   Theta(r) = acos((r^2+r0^2-1)/(2 r r0)) for r<=sqrt(r0^2-1), = asin(1/r0) beyond (increasing in r).
# Outward rounding: every float operation result is widened by 64 ulps (math.nextafter);
# libm acos/asin are assumed accurate to well under 30 ulp (sqrt is correctly rounded by IEEE 754).
import math
from fractions import Fraction as Fr
PARAMS = [  # (ea, eb, lam, k, j)
(0,0.005,0.21,0.0,0.0),(0.005,0.015,0.2065,0.0507,-0.0101),(0.015,0.025,0.2066,0.0995,-0.0084),
(0.025,0.035,0.2147,0.1373,-0.0078),(0.035,0.045,0.2085,0.1939,-0.0027),(0.045,0.055,0.208,0.241,0.0043),
(0.055,0.065,0.2151,0.2771,0.0082),(0.065,0.075,0.2092,0.3401,0.0155),(0.075,0.085,0.21,0.3837,0.0227),
(0.085,0.095,0.2178,0.4135,0.0314),(0.095,0.105,0.2208,0.4592,0.0516),(0.105,0.115,0.2139,0.5211,0.0553),
(0.115,0.125,0.2169,0.5675,0.0675),(0.125,0.135,0.2157,0.6247,0.0827),(0.135,0.145,0.2186,0.6632,0.1015),
(0.145,0.155,0.2211,0.7008,0.1122),(0.155,0.165,0.221,0.756,0.1319),(0.165,0.175,0.2281,0.7444,0.1207),
(0.175,0.185,0.2269,0.8281,0.1646),(0.185,0.195,0.2267,0.9021,0.2062),(0.195,0.205,0.2313,0.9091,0.2007),
(0.205,0.215,0.2316,0.9566,0.2193),(0.215,0.225,0.2364,0.9769,0.2326),(0.225,0.235,0.2401,1.034,0.2795),
(0.235,0.245,0.239,1.0748,0.2851),(0.245,0.255,0.2393,1.1103,0.2939),(0.255,0.265,0.2401,1.1894,0.3485),
(0.265,0.275,0.2473,1.1833,0.3553),(0.275,0.285,0.2457,1.2576,0.3913),(0.285,0.295,0.2504,1.2857,0.4197),
(0.295,0.305,0.2579,1.2879,0.4392),(0.305,0.315,0.2576,1.3238,0.4503),(0.315,0.325,0.2619,1.3633,0.4854),
(0.325,0.335,0.2719,1.3201,0.4774),(0.335,0.345,0.2644,1.4002,0.4958),(0.345,0.355,0.2719,1.3954,0.5128),
(0.355,0.365,0.2831,1.387,0.5304),(0.365,0.3684,0.2831,1.387,0.5304)]
def dn(x,n=64):
    for _ in range(n): x=math.nextafter(x,-math.inf)
    return x
def up(x,n=64):
    for _ in range(n): x=math.nextafter(x,math.inf)
    return x
def mul(a,b):
    p=[a[0]*b[0],a[0]*b[1],a[1]*b[0],a[1]*b[1]]; return (dn(min(p)),up(max(p)))
def add(a,b): return (dn(a[0]+b[0]),up(a[1]+b[1]))
def sub(a,b): return (dn(a[0]-b[1]),up(a[1]-b[0]))
def sc(k,a): return mul((k,k),a)
def sq(a):
    lo,hi=a
    if lo>=0: return (dn(lo*lo),up(hi*hi))
    if hi<=0: return (dn(hi*hi),up(lo*lo))
    return (0.0,up(max(lo*lo,hi*hi)))
def div(a,b):
    assert b[0]>0; return mul(a,(dn(1/b[1]),up(1/b[0])))
R0F=263169/100000            # float nearest to r0; true r0 lies in [R0LO,R0HI]
R0LO,R0HI=dn(R0F,1),up(R0F,1)
assert Fr(R0LO)<=Fr(263169,100000)<=Fr(R0HI)
RC_LO=dn(math.sqrt(dn(R0LO*R0LO-1)))   # lower bound for sqrt(r0^2-1)
A_HI=up(math.asin(up(1/R0LO)))         # upper bound for a(r0)=asin(1/r0) >= Theta everywhere
def theta_hi(r):   # upper bound for Theta(r) (Theta <= a(r0) always; theta=acos(q) decreasing in q)
    if r>=RC_LO: return A_HI
    num=dn(dn(dn(r*r)+dn(R0LO*R0LO))-1)
    den=up(up(2*r)*R0HI)
    q=max(-1.0,min(1.0,dn(num/den)))
    return min(A_HI,up(math.acos(q)))
PI10_LO=dn(math.pi/10)     # math.pi < true pi, so pi/10 > dn(...)
def Fhi(lam,k,j,E,Rr,S):
    e1,e2=E; r1,r2=Rr; s1,s2=S
    th=theta_hi(r2)
    if s1>=2: I=(0.0,0.0)
    else:
        s2c=min(s2,2.0)
        phi=(dn(math.acos(min(1.0,up(s2c/2)))),up(math.acos(dn(s1/2))))
        sp=(dn(math.sqrt(max(0.0,dn(1-up(s2c*s2c)/4)))),   # sin(phi)=sqrt(1-s^2/4),
            up(math.sqrt(max(0.0,up(1-dn(s1*s1)/4)))))      # decreasing in s
        s2p=mul((s1,s2c),sp)                  # sin(2phi)=s*sqrt(1-s^2/4)
        if k==0 and j==0: I=phi
        else:
            num=sub(sub(sq((r1,r2)),sq((s1,s2))),sq((e1,e2)))
            den=(dn(2*e1*s1),up(2*e2*s2))
            c=div(num,den); c=(max(-1.0,c[0]),min(1.0,c[1]))
            if c[0]>c[1]: return -9.0         # box contains no admissible point
            c2=sub(sc(2.0,sq(c)),(1.0,1.0))   # cos(2psi)=2cos^2-1
            I=add(sub(phi,sc(k,mul(sp,c))),sc(j/2,mul(s2p,c2)))
    oml=up(1-lam)                             # >= 1-lam
    return up(up(lam*I[1]) + up(oml*th))      # lam>=0, oml>=0, th>=0
def weight_nonneg(k,j):   # exact: w = (1-j) - k x + 2 j x^2 >= 0 on x in [-1,1]
    k=Fr(k); j=Fr(j)
    vals=[1+j-k,1+j+k]
    if j>0 and abs(k)<=4*j: vals.append(1-j-k*k/(8*j))
    return min(vals)>=0
def check(lam,k,j,E,maxn=10**7):
    e1,e2=E; rlo=dn(R0LO-1); rhi=up(3-e1)
    stack=[((e1,e2),(rlo,rhi),(max(1e-9,dn(rlo-e2)),up(rhi+e2)))]; n=0
    while stack:
        Eb,Rb,Sb=stack.pop(); n+=1
        if n>maxn: return False,n
        if Sb[0]>up(Rb[1]+Eb[1]) or Sb[1]<dn(Rb[0]-Eb[1]): continue
        if Fhi(lam,k,j,Eb,Rb,Sb)<PI10_LO: continue
        w=[(Eb[1]-Eb[0])*4,(Rb[1]-Rb[0]),(Sb[1]-Sb[0])]
        if max(w)<1e-7: return False,(Eb,Rb,Sb)
        i=w.index(max(w)); B=[Eb,Rb,Sb]; lo,hi=B[i]; m=(lo+hi)/2
        for part in ((lo,m),(m,hi)):
            B2=list(B); B2[i]=part; stack.append(tuple(B2))
    return True,n
tot=0; allok=True
assert PARAMS[0][0]==0 and PARAMS[-1][1]>=3-263169/100000
for (a,b,_,_,_),(c,_,_,_,_) in zip(PARAMS,PARAMS[1:]): assert b==c
for ea,eb,lam,k,j in PARAMS:
    assert 0<=lam<=1 and weight_nonneg(k,j)
    ok,n=check(lam,k,j,(ea,eb)); tot+=n if ok else 0; allok&=ok
    print(ea,eb,lam,k,j,"OK" if ok else "FAIL",n,flush=True)
print("ALL OK" if allok else "FAILURE","total boxes",tot)
