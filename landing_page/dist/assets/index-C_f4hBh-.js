(function(){const e=document.createElement("link").relList;if(e&&e.supports&&e.supports("modulepreload"))return;for(const i of document.querySelectorAll('link[rel="modulepreload"]'))n(i);new MutationObserver(i=>{for(const s of i)if(s.type==="childList")for(const a of s.addedNodes)a.tagName==="LINK"&&a.rel==="modulepreload"&&n(a)}).observe(document,{childList:!0,subtree:!0});function t(i){const s={};return i.integrity&&(s.integrity=i.integrity),i.referrerPolicy&&(s.referrerPolicy=i.referrerPolicy),i.crossOrigin==="use-credentials"?s.credentials="include":i.crossOrigin==="anonymous"?s.credentials="omit":s.credentials="same-origin",s}function n(i){if(i.ep)return;i.ep=!0;const s=t(i);fetch(i.href,s)}})();/**
 * @license
 * Copyright 2010-2024 Three.js Authors
 * SPDX-License-Identifier: MIT
 */const pu="171",Fp=0,Ku=1,Op=2,Ih=1,Bp=2,wi=3,or=0,Tn=1,Pi=2,nr=0,vs=1,zo=2,Zu=3,ju=4,zp=5,Rr=100,kp=101,Hp=102,Vp=103,Gp=104,Wp=200,Xp=201,qp=202,Yp=203,nc=204,ic=205,$p=206,Kp=207,Zp=208,jp=209,Jp=210,Qp=211,em=212,tm=213,nm=214,rc=0,sc=1,ac=2,ws=3,oc=4,lc=5,cc=6,uc=7,Uh=0,im=1,rm=2,ir=0,sm=1,am=2,om=3,lm=4,cm=5,um=6,fm=7,Nh=300,Rs=301,Cs=302,fc=303,hc=304,nl=306,dc=1e3,Pr=1001,pc=1002,fi=1003,hm=1004,Ba=1005,gi=1006,ul=1007,Dr=1008,zi=1009,Fh=1010,Oh=1011,Sa=1012,mu=1013,Hr=1014,Li=1015,Da=1016,_u=1017,gu=1018,Ps=1020,Bh=35902,zh=1021,kh=1022,ui=1023,Hh=1024,Vh=1025,xs=1026,Ds=1027,Gh=1028,vu=1029,Wh=1030,xu=1031,Mu=1033,To=33776,bo=33777,Ao=33778,wo=33779,mc=35840,_c=35841,gc=35842,vc=35843,xc=36196,Mc=37492,Sc=37496,yc=37808,Ec=37809,Tc=37810,bc=37811,Ac=37812,wc=37813,Rc=37814,Cc=37815,Pc=37816,Dc=37817,Lc=37818,Ic=37819,Uc=37820,Nc=37821,Ro=36492,Fc=36494,Oc=36495,Xh=36283,Bc=36284,zc=36285,kc=36286,dm=3200,pm=3201,mm=0,_m=1,Zi="",jn="srgb",Ls="srgb-linear",ko="linear",pt="srgb",$r=7680,Ju=519,gm=512,vm=513,xm=514,qh=515,Mm=516,Sm=517,ym=518,Em=519,Qu=35044,ef="300 es",Ii=2e3,Ho=2001;class Hs{addEventListener(e,t){this._listeners===void 0&&(this._listeners={});const n=this._listeners;n[e]===void 0&&(n[e]=[]),n[e].indexOf(t)===-1&&n[e].push(t)}hasEventListener(e,t){if(this._listeners===void 0)return!1;const n=this._listeners;return n[e]!==void 0&&n[e].indexOf(t)!==-1}removeEventListener(e,t){if(this._listeners===void 0)return;const i=this._listeners[e];if(i!==void 0){const s=i.indexOf(t);s!==-1&&i.splice(s,1)}}dispatchEvent(e){if(this._listeners===void 0)return;const n=this._listeners[e.type];if(n!==void 0){e.target=this;const i=n.slice(0);for(let s=0,a=i.length;s<a;s++)i[s].call(this,e);e.target=null}}}const tn=["00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f","10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f","20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f","30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f","40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f","50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f","60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f","70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f","80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f","90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f","a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af","b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf","c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf","d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df","e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef","f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"],fl=Math.PI/180,Hc=180/Math.PI;function La(){const r=Math.random()*4294967295|0,e=Math.random()*4294967295|0,t=Math.random()*4294967295|0,n=Math.random()*4294967295|0;return(tn[r&255]+tn[r>>8&255]+tn[r>>16&255]+tn[r>>24&255]+"-"+tn[e&255]+tn[e>>8&255]+"-"+tn[e>>16&15|64]+tn[e>>24&255]+"-"+tn[t&63|128]+tn[t>>8&255]+"-"+tn[t>>16&255]+tn[t>>24&255]+tn[n&255]+tn[n>>8&255]+tn[n>>16&255]+tn[n>>24&255]).toLowerCase()}function st(r,e,t){return Math.max(e,Math.min(t,r))}function Tm(r,e){return(r%e+e)%e}function hl(r,e,t){return(1-t)*r+t*e}function Xs(r,e){switch(e.constructor){case Float32Array:return r;case Uint32Array:return r/4294967295;case Uint16Array:return r/65535;case Uint8Array:return r/255;case Int32Array:return Math.max(r/2147483647,-1);case Int16Array:return Math.max(r/32767,-1);case Int8Array:return Math.max(r/127,-1);default:throw new Error("Invalid component type.")}}function Sn(r,e){switch(e.constructor){case Float32Array:return r;case Uint32Array:return Math.round(r*4294967295);case Uint16Array:return Math.round(r*65535);case Uint8Array:return Math.round(r*255);case Int32Array:return Math.round(r*2147483647);case Int16Array:return Math.round(r*32767);case Int8Array:return Math.round(r*127);default:throw new Error("Invalid component type.")}}class Mt{constructor(e=0,t=0){Mt.prototype.isVector2=!0,this.x=e,this.y=t}get width(){return this.x}set width(e){this.x=e}get height(){return this.y}set height(e){this.y=e}set(e,t){return this.x=e,this.y=t,this}setScalar(e){return this.x=e,this.y=e,this}setX(e){return this.x=e,this}setY(e){return this.y=e,this}setComponent(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;default:throw new Error("index is out of range: "+e)}return this}getComponent(e){switch(e){case 0:return this.x;case 1:return this.y;default:throw new Error("index is out of range: "+e)}}clone(){return new this.constructor(this.x,this.y)}copy(e){return this.x=e.x,this.y=e.y,this}add(e){return this.x+=e.x,this.y+=e.y,this}addScalar(e){return this.x+=e,this.y+=e,this}addVectors(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this}addScaledVector(e,t){return this.x+=e.x*t,this.y+=e.y*t,this}sub(e){return this.x-=e.x,this.y-=e.y,this}subScalar(e){return this.x-=e,this.y-=e,this}subVectors(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this}multiply(e){return this.x*=e.x,this.y*=e.y,this}multiplyScalar(e){return this.x*=e,this.y*=e,this}divide(e){return this.x/=e.x,this.y/=e.y,this}divideScalar(e){return this.multiplyScalar(1/e)}applyMatrix3(e){const t=this.x,n=this.y,i=e.elements;return this.x=i[0]*t+i[3]*n+i[6],this.y=i[1]*t+i[4]*n+i[7],this}min(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this}max(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this}clamp(e,t){return this.x=st(this.x,e.x,t.x),this.y=st(this.y,e.y,t.y),this}clampScalar(e,t){return this.x=st(this.x,e,t),this.y=st(this.y,e,t),this}clampLength(e,t){const n=this.length();return this.divideScalar(n||1).multiplyScalar(st(n,e,t))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this}negate(){return this.x=-this.x,this.y=-this.y,this}dot(e){return this.x*e.x+this.y*e.y}cross(e){return this.x*e.y-this.y*e.x}lengthSq(){return this.x*this.x+this.y*this.y}length(){return Math.sqrt(this.x*this.x+this.y*this.y)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)}normalize(){return this.divideScalar(this.length()||1)}angle(){return Math.atan2(-this.y,-this.x)+Math.PI}angleTo(e){const t=Math.sqrt(this.lengthSq()*e.lengthSq());if(t===0)return Math.PI/2;const n=this.dot(e)/t;return Math.acos(st(n,-1,1))}distanceTo(e){return Math.sqrt(this.distanceToSquared(e))}distanceToSquared(e){const t=this.x-e.x,n=this.y-e.y;return t*t+n*n}manhattanDistanceTo(e){return Math.abs(this.x-e.x)+Math.abs(this.y-e.y)}setLength(e){return this.normalize().multiplyScalar(e)}lerp(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this}lerpVectors(e,t,n){return this.x=e.x+(t.x-e.x)*n,this.y=e.y+(t.y-e.y)*n,this}equals(e){return e.x===this.x&&e.y===this.y}fromArray(e,t=0){return this.x=e[t],this.y=e[t+1],this}toArray(e=[],t=0){return e[t]=this.x,e[t+1]=this.y,e}fromBufferAttribute(e,t){return this.x=e.getX(t),this.y=e.getY(t),this}rotateAround(e,t){const n=Math.cos(t),i=Math.sin(t),s=this.x-e.x,a=this.y-e.y;return this.x=s*n-a*i+e.x,this.y=s*i+a*n+e.y,this}random(){return this.x=Math.random(),this.y=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y}}class qe{constructor(e,t,n,i,s,a,o,l,c){qe.prototype.isMatrix3=!0,this.elements=[1,0,0,0,1,0,0,0,1],e!==void 0&&this.set(e,t,n,i,s,a,o,l,c)}set(e,t,n,i,s,a,o,l,c){const u=this.elements;return u[0]=e,u[1]=i,u[2]=o,u[3]=t,u[4]=s,u[5]=l,u[6]=n,u[7]=a,u[8]=c,this}identity(){return this.set(1,0,0,0,1,0,0,0,1),this}copy(e){const t=this.elements,n=e.elements;return t[0]=n[0],t[1]=n[1],t[2]=n[2],t[3]=n[3],t[4]=n[4],t[5]=n[5],t[6]=n[6],t[7]=n[7],t[8]=n[8],this}extractBasis(e,t,n){return e.setFromMatrix3Column(this,0),t.setFromMatrix3Column(this,1),n.setFromMatrix3Column(this,2),this}setFromMatrix4(e){const t=e.elements;return this.set(t[0],t[4],t[8],t[1],t[5],t[9],t[2],t[6],t[10]),this}multiply(e){return this.multiplyMatrices(this,e)}premultiply(e){return this.multiplyMatrices(e,this)}multiplyMatrices(e,t){const n=e.elements,i=t.elements,s=this.elements,a=n[0],o=n[3],l=n[6],c=n[1],u=n[4],h=n[7],d=n[2],f=n[5],g=n[8],_=i[0],m=i[3],p=i[6],T=i[1],E=i[4],x=i[7],R=i[2],w=i[5],b=i[8];return s[0]=a*_+o*T+l*R,s[3]=a*m+o*E+l*w,s[6]=a*p+o*x+l*b,s[1]=c*_+u*T+h*R,s[4]=c*m+u*E+h*w,s[7]=c*p+u*x+h*b,s[2]=d*_+f*T+g*R,s[5]=d*m+f*E+g*w,s[8]=d*p+f*x+g*b,this}multiplyScalar(e){const t=this.elements;return t[0]*=e,t[3]*=e,t[6]*=e,t[1]*=e,t[4]*=e,t[7]*=e,t[2]*=e,t[5]*=e,t[8]*=e,this}determinant(){const e=this.elements,t=e[0],n=e[1],i=e[2],s=e[3],a=e[4],o=e[5],l=e[6],c=e[7],u=e[8];return t*a*u-t*o*c-n*s*u+n*o*l+i*s*c-i*a*l}invert(){const e=this.elements,t=e[0],n=e[1],i=e[2],s=e[3],a=e[4],o=e[5],l=e[6],c=e[7],u=e[8],h=u*a-o*c,d=o*l-u*s,f=c*s-a*l,g=t*h+n*d+i*f;if(g===0)return this.set(0,0,0,0,0,0,0,0,0);const _=1/g;return e[0]=h*_,e[1]=(i*c-u*n)*_,e[2]=(o*n-i*a)*_,e[3]=d*_,e[4]=(u*t-i*l)*_,e[5]=(i*s-o*t)*_,e[6]=f*_,e[7]=(n*l-c*t)*_,e[8]=(a*t-n*s)*_,this}transpose(){let e;const t=this.elements;return e=t[1],t[1]=t[3],t[3]=e,e=t[2],t[2]=t[6],t[6]=e,e=t[5],t[5]=t[7],t[7]=e,this}getNormalMatrix(e){return this.setFromMatrix4(e).invert().transpose()}transposeIntoArray(e){const t=this.elements;return e[0]=t[0],e[1]=t[3],e[2]=t[6],e[3]=t[1],e[4]=t[4],e[5]=t[7],e[6]=t[2],e[7]=t[5],e[8]=t[8],this}setUvTransform(e,t,n,i,s,a,o){const l=Math.cos(s),c=Math.sin(s);return this.set(n*l,n*c,-n*(l*a+c*o)+a+e,-i*c,i*l,-i*(-c*a+l*o)+o+t,0,0,1),this}scale(e,t){return this.premultiply(dl.makeScale(e,t)),this}rotate(e){return this.premultiply(dl.makeRotation(-e)),this}translate(e,t){return this.premultiply(dl.makeTranslation(e,t)),this}makeTranslation(e,t){return e.isVector2?this.set(1,0,e.x,0,1,e.y,0,0,1):this.set(1,0,e,0,1,t,0,0,1),this}makeRotation(e){const t=Math.cos(e),n=Math.sin(e);return this.set(t,-n,0,n,t,0,0,0,1),this}makeScale(e,t){return this.set(e,0,0,0,t,0,0,0,1),this}equals(e){const t=this.elements,n=e.elements;for(let i=0;i<9;i++)if(t[i]!==n[i])return!1;return!0}fromArray(e,t=0){for(let n=0;n<9;n++)this.elements[n]=e[n+t];return this}toArray(e=[],t=0){const n=this.elements;return e[t]=n[0],e[t+1]=n[1],e[t+2]=n[2],e[t+3]=n[3],e[t+4]=n[4],e[t+5]=n[5],e[t+6]=n[6],e[t+7]=n[7],e[t+8]=n[8],e}clone(){return new this.constructor().fromArray(this.elements)}}const dl=new qe;function Yh(r){for(let e=r.length-1;e>=0;--e)if(r[e]>=65535)return!0;return!1}function Vo(r){return document.createElementNS("http://www.w3.org/1999/xhtml",r)}function bm(){const r=Vo("canvas");return r.style.display="block",r}const tf={};function fs(r){r in tf||(tf[r]=!0,console.warn(r))}function Am(r,e,t){return new Promise(function(n,i){function s(){switch(r.clientWaitSync(e,r.SYNC_FLUSH_COMMANDS_BIT,0)){case r.WAIT_FAILED:i();break;case r.TIMEOUT_EXPIRED:setTimeout(s,t);break;default:n()}}setTimeout(s,t)})}function wm(r){const e=r.elements;e[2]=.5*e[2]+.5*e[3],e[6]=.5*e[6]+.5*e[7],e[10]=.5*e[10]+.5*e[11],e[14]=.5*e[14]+.5*e[15]}function Rm(r){const e=r.elements;e[11]===-1?(e[10]=-e[10]-1,e[14]=-e[14]):(e[10]=-e[10],e[14]=-e[14]+1)}const nf=new qe().set(.4123908,.3575843,.1804808,.212639,.7151687,.0721923,.0193308,.1191948,.9505322),rf=new qe().set(3.2409699,-1.5373832,-.4986108,-.9692436,1.8759675,.0415551,.0556301,-.203977,1.0569715);function Cm(){const r={enabled:!0,workingColorSpace:Ls,spaces:{},convert:function(i,s,a){return this.enabled===!1||s===a||!s||!a||(this.spaces[s].transfer===pt&&(i.r=Fi(i.r),i.g=Fi(i.g),i.b=Fi(i.b)),this.spaces[s].primaries!==this.spaces[a].primaries&&(i.applyMatrix3(this.spaces[s].toXYZ),i.applyMatrix3(this.spaces[a].fromXYZ)),this.spaces[a].transfer===pt&&(i.r=Ms(i.r),i.g=Ms(i.g),i.b=Ms(i.b))),i},fromWorkingColorSpace:function(i,s){return this.convert(i,this.workingColorSpace,s)},toWorkingColorSpace:function(i,s){return this.convert(i,s,this.workingColorSpace)},getPrimaries:function(i){return this.spaces[i].primaries},getTransfer:function(i){return i===Zi?ko:this.spaces[i].transfer},getLuminanceCoefficients:function(i,s=this.workingColorSpace){return i.fromArray(this.spaces[s].luminanceCoefficients)},define:function(i){Object.assign(this.spaces,i)},_getMatrix:function(i,s,a){return i.copy(this.spaces[s].toXYZ).multiply(this.spaces[a].fromXYZ)},_getDrawingBufferColorSpace:function(i){return this.spaces[i].outputColorSpaceConfig.drawingBufferColorSpace},_getUnpackColorSpace:function(i=this.workingColorSpace){return this.spaces[i].workingColorSpaceConfig.unpackColorSpace}},e=[.64,.33,.3,.6,.15,.06],t=[.2126,.7152,.0722],n=[.3127,.329];return r.define({[Ls]:{primaries:e,whitePoint:n,transfer:ko,toXYZ:nf,fromXYZ:rf,luminanceCoefficients:t,workingColorSpaceConfig:{unpackColorSpace:jn},outputColorSpaceConfig:{drawingBufferColorSpace:jn}},[jn]:{primaries:e,whitePoint:n,transfer:pt,toXYZ:nf,fromXYZ:rf,luminanceCoefficients:t,outputColorSpaceConfig:{drawingBufferColorSpace:jn}}}),r}const ut=Cm();function Fi(r){return r<.04045?r*.0773993808:Math.pow(r*.9478672986+.0521327014,2.4)}function Ms(r){return r<.0031308?r*12.92:1.055*Math.pow(r,.41666)-.055}let Kr;class Pm{static getDataURL(e){if(/^data:/i.test(e.src)||typeof HTMLCanvasElement>"u")return e.src;let t;if(e instanceof HTMLCanvasElement)t=e;else{Kr===void 0&&(Kr=Vo("canvas")),Kr.width=e.width,Kr.height=e.height;const n=Kr.getContext("2d");e instanceof ImageData?n.putImageData(e,0,0):n.drawImage(e,0,0,e.width,e.height),t=Kr}return t.width>2048||t.height>2048?(console.warn("THREE.ImageUtils.getDataURL: Image converted to jpg for performance reasons",e),t.toDataURL("image/jpeg",.6)):t.toDataURL("image/png")}static sRGBToLinear(e){if(typeof HTMLImageElement<"u"&&e instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&e instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&e instanceof ImageBitmap){const t=Vo("canvas");t.width=e.width,t.height=e.height;const n=t.getContext("2d");n.drawImage(e,0,0,e.width,e.height);const i=n.getImageData(0,0,e.width,e.height),s=i.data;for(let a=0;a<s.length;a++)s[a]=Fi(s[a]/255)*255;return n.putImageData(i,0,0),t}else if(e.data){const t=e.data.slice(0);for(let n=0;n<t.length;n++)t instanceof Uint8Array||t instanceof Uint8ClampedArray?t[n]=Math.floor(Fi(t[n]/255)*255):t[n]=Fi(t[n]);return{data:t,width:e.width,height:e.height}}else return console.warn("THREE.ImageUtils.sRGBToLinear(): Unsupported image type. No color space conversion applied."),e}}let Dm=0;class $h{constructor(e=null){this.isSource=!0,Object.defineProperty(this,"id",{value:Dm++}),this.uuid=La(),this.data=e,this.dataReady=!0,this.version=0}set needsUpdate(e){e===!0&&this.version++}toJSON(e){const t=e===void 0||typeof e=="string";if(!t&&e.images[this.uuid]!==void 0)return e.images[this.uuid];const n={uuid:this.uuid,url:""},i=this.data;if(i!==null){let s;if(Array.isArray(i)){s=[];for(let a=0,o=i.length;a<o;a++)i[a].isDataTexture?s.push(pl(i[a].image)):s.push(pl(i[a]))}else s=pl(i);n.url=s}return t||(e.images[this.uuid]=n),n}}function pl(r){return typeof HTMLImageElement<"u"&&r instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&r instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&r instanceof ImageBitmap?Pm.getDataURL(r):r.data?{data:Array.from(r.data),width:r.width,height:r.height,type:r.data.constructor.name}:(console.warn("THREE.Texture: Unable to serialize Texture."),{})}let Lm=0;class bn extends Hs{constructor(e=bn.DEFAULT_IMAGE,t=bn.DEFAULT_MAPPING,n=Pr,i=Pr,s=gi,a=Dr,o=ui,l=zi,c=bn.DEFAULT_ANISOTROPY,u=Zi){super(),this.isTexture=!0,Object.defineProperty(this,"id",{value:Lm++}),this.uuid=La(),this.name="",this.source=new $h(e),this.mipmaps=[],this.mapping=t,this.channel=0,this.wrapS=n,this.wrapT=i,this.magFilter=s,this.minFilter=a,this.anisotropy=c,this.format=o,this.internalFormat=null,this.type=l,this.offset=new Mt(0,0),this.repeat=new Mt(1,1),this.center=new Mt(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new qe,this.generateMipmaps=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,this.colorSpace=u,this.userData={},this.version=0,this.onUpdate=null,this.isRenderTargetTexture=!1,this.pmremVersion=0}get image(){return this.source.data}set image(e=null){this.source.data=e}updateMatrix(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)}clone(){return new this.constructor().copy(this)}copy(e){return this.name=e.name,this.source=e.source,this.mipmaps=e.mipmaps.slice(0),this.mapping=e.mapping,this.channel=e.channel,this.wrapS=e.wrapS,this.wrapT=e.wrapT,this.magFilter=e.magFilter,this.minFilter=e.minFilter,this.anisotropy=e.anisotropy,this.format=e.format,this.internalFormat=e.internalFormat,this.type=e.type,this.offset.copy(e.offset),this.repeat.copy(e.repeat),this.center.copy(e.center),this.rotation=e.rotation,this.matrixAutoUpdate=e.matrixAutoUpdate,this.matrix.copy(e.matrix),this.generateMipmaps=e.generateMipmaps,this.premultiplyAlpha=e.premultiplyAlpha,this.flipY=e.flipY,this.unpackAlignment=e.unpackAlignment,this.colorSpace=e.colorSpace,this.userData=JSON.parse(JSON.stringify(e.userData)),this.needsUpdate=!0,this}toJSON(e){const t=e===void 0||typeof e=="string";if(!t&&e.textures[this.uuid]!==void 0)return e.textures[this.uuid];const n={metadata:{version:4.6,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,image:this.source.toJSON(e).uuid,mapping:this.mapping,channel:this.channel,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,internalFormat:this.internalFormat,type:this.type,colorSpace:this.colorSpace,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,generateMipmaps:this.generateMipmaps,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};return Object.keys(this.userData).length>0&&(n.userData=this.userData),t||(e.textures[this.uuid]=n),n}dispose(){this.dispatchEvent({type:"dispose"})}transformUv(e){if(this.mapping!==Nh)return e;if(e.applyMatrix3(this.matrix),e.x<0||e.x>1)switch(this.wrapS){case dc:e.x=e.x-Math.floor(e.x);break;case Pr:e.x=e.x<0?0:1;break;case pc:Math.abs(Math.floor(e.x)%2)===1?e.x=Math.ceil(e.x)-e.x:e.x=e.x-Math.floor(e.x);break}if(e.y<0||e.y>1)switch(this.wrapT){case dc:e.y=e.y-Math.floor(e.y);break;case Pr:e.y=e.y<0?0:1;break;case pc:Math.abs(Math.floor(e.y)%2)===1?e.y=Math.ceil(e.y)-e.y:e.y=e.y-Math.floor(e.y);break}return this.flipY&&(e.y=1-e.y),e}set needsUpdate(e){e===!0&&(this.version++,this.source.needsUpdate=!0)}set needsPMREMUpdate(e){e===!0&&this.pmremVersion++}}bn.DEFAULT_IMAGE=null;bn.DEFAULT_MAPPING=Nh;bn.DEFAULT_ANISOTROPY=1;class Nt{constructor(e=0,t=0,n=0,i=1){Nt.prototype.isVector4=!0,this.x=e,this.y=t,this.z=n,this.w=i}get width(){return this.z}set width(e){this.z=e}get height(){return this.w}set height(e){this.w=e}set(e,t,n,i){return this.x=e,this.y=t,this.z=n,this.w=i,this}setScalar(e){return this.x=e,this.y=e,this.z=e,this.w=e,this}setX(e){return this.x=e,this}setY(e){return this.y=e,this}setZ(e){return this.z=e,this}setW(e){return this.w=e,this}setComponent(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;case 2:this.z=t;break;case 3:this.w=t;break;default:throw new Error("index is out of range: "+e)}return this}getComponent(e){switch(e){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("index is out of range: "+e)}}clone(){return new this.constructor(this.x,this.y,this.z,this.w)}copy(e){return this.x=e.x,this.y=e.y,this.z=e.z,this.w=e.w!==void 0?e.w:1,this}add(e){return this.x+=e.x,this.y+=e.y,this.z+=e.z,this.w+=e.w,this}addScalar(e){return this.x+=e,this.y+=e,this.z+=e,this.w+=e,this}addVectors(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this.z=e.z+t.z,this.w=e.w+t.w,this}addScaledVector(e,t){return this.x+=e.x*t,this.y+=e.y*t,this.z+=e.z*t,this.w+=e.w*t,this}sub(e){return this.x-=e.x,this.y-=e.y,this.z-=e.z,this.w-=e.w,this}subScalar(e){return this.x-=e,this.y-=e,this.z-=e,this.w-=e,this}subVectors(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this.z=e.z-t.z,this.w=e.w-t.w,this}multiply(e){return this.x*=e.x,this.y*=e.y,this.z*=e.z,this.w*=e.w,this}multiplyScalar(e){return this.x*=e,this.y*=e,this.z*=e,this.w*=e,this}applyMatrix4(e){const t=this.x,n=this.y,i=this.z,s=this.w,a=e.elements;return this.x=a[0]*t+a[4]*n+a[8]*i+a[12]*s,this.y=a[1]*t+a[5]*n+a[9]*i+a[13]*s,this.z=a[2]*t+a[6]*n+a[10]*i+a[14]*s,this.w=a[3]*t+a[7]*n+a[11]*i+a[15]*s,this}divide(e){return this.x/=e.x,this.y/=e.y,this.z/=e.z,this.w/=e.w,this}divideScalar(e){return this.multiplyScalar(1/e)}setAxisAngleFromQuaternion(e){this.w=2*Math.acos(e.w);const t=Math.sqrt(1-e.w*e.w);return t<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=e.x/t,this.y=e.y/t,this.z=e.z/t),this}setAxisAngleFromRotationMatrix(e){let t,n,i,s;const l=e.elements,c=l[0],u=l[4],h=l[8],d=l[1],f=l[5],g=l[9],_=l[2],m=l[6],p=l[10];if(Math.abs(u-d)<.01&&Math.abs(h-_)<.01&&Math.abs(g-m)<.01){if(Math.abs(u+d)<.1&&Math.abs(h+_)<.1&&Math.abs(g+m)<.1&&Math.abs(c+f+p-3)<.1)return this.set(1,0,0,0),this;t=Math.PI;const E=(c+1)/2,x=(f+1)/2,R=(p+1)/2,w=(u+d)/4,b=(h+_)/4,C=(g+m)/4;return E>x&&E>R?E<.01?(n=0,i=.707106781,s=.707106781):(n=Math.sqrt(E),i=w/n,s=b/n):x>R?x<.01?(n=.707106781,i=0,s=.707106781):(i=Math.sqrt(x),n=w/i,s=C/i):R<.01?(n=.707106781,i=.707106781,s=0):(s=Math.sqrt(R),n=b/s,i=C/s),this.set(n,i,s,t),this}let T=Math.sqrt((m-g)*(m-g)+(h-_)*(h-_)+(d-u)*(d-u));return Math.abs(T)<.001&&(T=1),this.x=(m-g)/T,this.y=(h-_)/T,this.z=(d-u)/T,this.w=Math.acos((c+f+p-1)/2),this}setFromMatrixPosition(e){const t=e.elements;return this.x=t[12],this.y=t[13],this.z=t[14],this.w=t[15],this}min(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this.z=Math.min(this.z,e.z),this.w=Math.min(this.w,e.w),this}max(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this.z=Math.max(this.z,e.z),this.w=Math.max(this.w,e.w),this}clamp(e,t){return this.x=st(this.x,e.x,t.x),this.y=st(this.y,e.y,t.y),this.z=st(this.z,e.z,t.z),this.w=st(this.w,e.w,t.w),this}clampScalar(e,t){return this.x=st(this.x,e,t),this.y=st(this.y,e,t),this.z=st(this.z,e,t),this.w=st(this.w,e,t),this}clampLength(e,t){const n=this.length();return this.divideScalar(n||1).multiplyScalar(st(n,e,t))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this.w=Math.trunc(this.w),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this}dot(e){return this.x*e.x+this.y*e.y+this.z*e.z+this.w*e.w}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)}normalize(){return this.divideScalar(this.length()||1)}setLength(e){return this.normalize().multiplyScalar(e)}lerp(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this.z+=(e.z-this.z)*t,this.w+=(e.w-this.w)*t,this}lerpVectors(e,t,n){return this.x=e.x+(t.x-e.x)*n,this.y=e.y+(t.y-e.y)*n,this.z=e.z+(t.z-e.z)*n,this.w=e.w+(t.w-e.w)*n,this}equals(e){return e.x===this.x&&e.y===this.y&&e.z===this.z&&e.w===this.w}fromArray(e,t=0){return this.x=e[t],this.y=e[t+1],this.z=e[t+2],this.w=e[t+3],this}toArray(e=[],t=0){return e[t]=this.x,e[t+1]=this.y,e[t+2]=this.z,e[t+3]=this.w,e}fromBufferAttribute(e,t){return this.x=e.getX(t),this.y=e.getY(t),this.z=e.getZ(t),this.w=e.getW(t),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this.w=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z,yield this.w}}class Im extends Hs{constructor(e=1,t=1,n={}){super(),this.isRenderTarget=!0,this.width=e,this.height=t,this.depth=1,this.scissor=new Nt(0,0,e,t),this.scissorTest=!1,this.viewport=new Nt(0,0,e,t);const i={width:e,height:t,depth:1};n=Object.assign({generateMipmaps:!1,internalFormat:null,minFilter:gi,depthBuffer:!0,stencilBuffer:!1,resolveDepthBuffer:!0,resolveStencilBuffer:!0,depthTexture:null,samples:0,count:1},n);const s=new bn(i,n.mapping,n.wrapS,n.wrapT,n.magFilter,n.minFilter,n.format,n.type,n.anisotropy,n.colorSpace);s.flipY=!1,s.generateMipmaps=n.generateMipmaps,s.internalFormat=n.internalFormat,this.textures=[];const a=n.count;for(let o=0;o<a;o++)this.textures[o]=s.clone(),this.textures[o].isRenderTargetTexture=!0;this.depthBuffer=n.depthBuffer,this.stencilBuffer=n.stencilBuffer,this.resolveDepthBuffer=n.resolveDepthBuffer,this.resolveStencilBuffer=n.resolveStencilBuffer,this.depthTexture=n.depthTexture,this.samples=n.samples}get texture(){return this.textures[0]}set texture(e){this.textures[0]=e}setSize(e,t,n=1){if(this.width!==e||this.height!==t||this.depth!==n){this.width=e,this.height=t,this.depth=n;for(let i=0,s=this.textures.length;i<s;i++)this.textures[i].image.width=e,this.textures[i].image.height=t,this.textures[i].image.depth=n;this.dispose()}this.viewport.set(0,0,e,t),this.scissor.set(0,0,e,t)}clone(){return new this.constructor().copy(this)}copy(e){this.width=e.width,this.height=e.height,this.depth=e.depth,this.scissor.copy(e.scissor),this.scissorTest=e.scissorTest,this.viewport.copy(e.viewport),this.textures.length=0;for(let n=0,i=e.textures.length;n<i;n++)this.textures[n]=e.textures[n].clone(),this.textures[n].isRenderTargetTexture=!0;const t=Object.assign({},e.texture.image);return this.texture.source=new $h(t),this.depthBuffer=e.depthBuffer,this.stencilBuffer=e.stencilBuffer,this.resolveDepthBuffer=e.resolveDepthBuffer,this.resolveStencilBuffer=e.resolveStencilBuffer,e.depthTexture!==null&&(this.depthTexture=e.depthTexture.clone()),this.samples=e.samples,this}dispose(){this.dispatchEvent({type:"dispose"})}}class Vr extends Im{constructor(e=1,t=1,n={}){super(e,t,n),this.isWebGLRenderTarget=!0}}class Kh extends bn{constructor(e=null,t=1,n=1,i=1){super(null),this.isDataArrayTexture=!0,this.image={data:e,width:t,height:n,depth:i},this.magFilter=fi,this.minFilter=fi,this.wrapR=Pr,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1,this.layerUpdates=new Set}addLayerUpdate(e){this.layerUpdates.add(e)}clearLayerUpdates(){this.layerUpdates.clear()}}class Um extends bn{constructor(e=null,t=1,n=1,i=1){super(null),this.isData3DTexture=!0,this.image={data:e,width:t,height:n,depth:i},this.magFilter=fi,this.minFilter=fi,this.wrapR=Pr,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}}class Ia{constructor(e=0,t=0,n=0,i=1){this.isQuaternion=!0,this._x=e,this._y=t,this._z=n,this._w=i}static slerpFlat(e,t,n,i,s,a,o){let l=n[i+0],c=n[i+1],u=n[i+2],h=n[i+3];const d=s[a+0],f=s[a+1],g=s[a+2],_=s[a+3];if(o===0){e[t+0]=l,e[t+1]=c,e[t+2]=u,e[t+3]=h;return}if(o===1){e[t+0]=d,e[t+1]=f,e[t+2]=g,e[t+3]=_;return}if(h!==_||l!==d||c!==f||u!==g){let m=1-o;const p=l*d+c*f+u*g+h*_,T=p>=0?1:-1,E=1-p*p;if(E>Number.EPSILON){const R=Math.sqrt(E),w=Math.atan2(R,p*T);m=Math.sin(m*w)/R,o=Math.sin(o*w)/R}const x=o*T;if(l=l*m+d*x,c=c*m+f*x,u=u*m+g*x,h=h*m+_*x,m===1-o){const R=1/Math.sqrt(l*l+c*c+u*u+h*h);l*=R,c*=R,u*=R,h*=R}}e[t]=l,e[t+1]=c,e[t+2]=u,e[t+3]=h}static multiplyQuaternionsFlat(e,t,n,i,s,a){const o=n[i],l=n[i+1],c=n[i+2],u=n[i+3],h=s[a],d=s[a+1],f=s[a+2],g=s[a+3];return e[t]=o*g+u*h+l*f-c*d,e[t+1]=l*g+u*d+c*h-o*f,e[t+2]=c*g+u*f+o*d-l*h,e[t+3]=u*g-o*h-l*d-c*f,e}get x(){return this._x}set x(e){this._x=e,this._onChangeCallback()}get y(){return this._y}set y(e){this._y=e,this._onChangeCallback()}get z(){return this._z}set z(e){this._z=e,this._onChangeCallback()}get w(){return this._w}set w(e){this._w=e,this._onChangeCallback()}set(e,t,n,i){return this._x=e,this._y=t,this._z=n,this._w=i,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._w)}copy(e){return this._x=e.x,this._y=e.y,this._z=e.z,this._w=e.w,this._onChangeCallback(),this}setFromEuler(e,t=!0){const n=e._x,i=e._y,s=e._z,a=e._order,o=Math.cos,l=Math.sin,c=o(n/2),u=o(i/2),h=o(s/2),d=l(n/2),f=l(i/2),g=l(s/2);switch(a){case"XYZ":this._x=d*u*h+c*f*g,this._y=c*f*h-d*u*g,this._z=c*u*g+d*f*h,this._w=c*u*h-d*f*g;break;case"YXZ":this._x=d*u*h+c*f*g,this._y=c*f*h-d*u*g,this._z=c*u*g-d*f*h,this._w=c*u*h+d*f*g;break;case"ZXY":this._x=d*u*h-c*f*g,this._y=c*f*h+d*u*g,this._z=c*u*g+d*f*h,this._w=c*u*h-d*f*g;break;case"ZYX":this._x=d*u*h-c*f*g,this._y=c*f*h+d*u*g,this._z=c*u*g-d*f*h,this._w=c*u*h+d*f*g;break;case"YZX":this._x=d*u*h+c*f*g,this._y=c*f*h+d*u*g,this._z=c*u*g-d*f*h,this._w=c*u*h-d*f*g;break;case"XZY":this._x=d*u*h-c*f*g,this._y=c*f*h-d*u*g,this._z=c*u*g+d*f*h,this._w=c*u*h+d*f*g;break;default:console.warn("THREE.Quaternion: .setFromEuler() encountered an unknown order: "+a)}return t===!0&&this._onChangeCallback(),this}setFromAxisAngle(e,t){const n=t/2,i=Math.sin(n);return this._x=e.x*i,this._y=e.y*i,this._z=e.z*i,this._w=Math.cos(n),this._onChangeCallback(),this}setFromRotationMatrix(e){const t=e.elements,n=t[0],i=t[4],s=t[8],a=t[1],o=t[5],l=t[9],c=t[2],u=t[6],h=t[10],d=n+o+h;if(d>0){const f=.5/Math.sqrt(d+1);this._w=.25/f,this._x=(u-l)*f,this._y=(s-c)*f,this._z=(a-i)*f}else if(n>o&&n>h){const f=2*Math.sqrt(1+n-o-h);this._w=(u-l)/f,this._x=.25*f,this._y=(i+a)/f,this._z=(s+c)/f}else if(o>h){const f=2*Math.sqrt(1+o-n-h);this._w=(s-c)/f,this._x=(i+a)/f,this._y=.25*f,this._z=(l+u)/f}else{const f=2*Math.sqrt(1+h-n-o);this._w=(a-i)/f,this._x=(s+c)/f,this._y=(l+u)/f,this._z=.25*f}return this._onChangeCallback(),this}setFromUnitVectors(e,t){let n=e.dot(t)+1;return n<Number.EPSILON?(n=0,Math.abs(e.x)>Math.abs(e.z)?(this._x=-e.y,this._y=e.x,this._z=0,this._w=n):(this._x=0,this._y=-e.z,this._z=e.y,this._w=n)):(this._x=e.y*t.z-e.z*t.y,this._y=e.z*t.x-e.x*t.z,this._z=e.x*t.y-e.y*t.x,this._w=n),this.normalize()}angleTo(e){return 2*Math.acos(Math.abs(st(this.dot(e),-1,1)))}rotateTowards(e,t){const n=this.angleTo(e);if(n===0)return this;const i=Math.min(1,t/n);return this.slerp(e,i),this}identity(){return this.set(0,0,0,1)}invert(){return this.conjugate()}conjugate(){return this._x*=-1,this._y*=-1,this._z*=-1,this._onChangeCallback(),this}dot(e){return this._x*e._x+this._y*e._y+this._z*e._z+this._w*e._w}lengthSq(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w}length(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)}normalize(){let e=this.length();return e===0?(this._x=0,this._y=0,this._z=0,this._w=1):(e=1/e,this._x=this._x*e,this._y=this._y*e,this._z=this._z*e,this._w=this._w*e),this._onChangeCallback(),this}multiply(e){return this.multiplyQuaternions(this,e)}premultiply(e){return this.multiplyQuaternions(e,this)}multiplyQuaternions(e,t){const n=e._x,i=e._y,s=e._z,a=e._w,o=t._x,l=t._y,c=t._z,u=t._w;return this._x=n*u+a*o+i*c-s*l,this._y=i*u+a*l+s*o-n*c,this._z=s*u+a*c+n*l-i*o,this._w=a*u-n*o-i*l-s*c,this._onChangeCallback(),this}slerp(e,t){if(t===0)return this;if(t===1)return this.copy(e);const n=this._x,i=this._y,s=this._z,a=this._w;let o=a*e._w+n*e._x+i*e._y+s*e._z;if(o<0?(this._w=-e._w,this._x=-e._x,this._y=-e._y,this._z=-e._z,o=-o):this.copy(e),o>=1)return this._w=a,this._x=n,this._y=i,this._z=s,this;const l=1-o*o;if(l<=Number.EPSILON){const f=1-t;return this._w=f*a+t*this._w,this._x=f*n+t*this._x,this._y=f*i+t*this._y,this._z=f*s+t*this._z,this.normalize(),this}const c=Math.sqrt(l),u=Math.atan2(c,o),h=Math.sin((1-t)*u)/c,d=Math.sin(t*u)/c;return this._w=a*h+this._w*d,this._x=n*h+this._x*d,this._y=i*h+this._y*d,this._z=s*h+this._z*d,this._onChangeCallback(),this}slerpQuaternions(e,t,n){return this.copy(e).slerp(t,n)}random(){const e=2*Math.PI*Math.random(),t=2*Math.PI*Math.random(),n=Math.random(),i=Math.sqrt(1-n),s=Math.sqrt(n);return this.set(i*Math.sin(e),i*Math.cos(e),s*Math.sin(t),s*Math.cos(t))}equals(e){return e._x===this._x&&e._y===this._y&&e._z===this._z&&e._w===this._w}fromArray(e,t=0){return this._x=e[t],this._y=e[t+1],this._z=e[t+2],this._w=e[t+3],this._onChangeCallback(),this}toArray(e=[],t=0){return e[t]=this._x,e[t+1]=this._y,e[t+2]=this._z,e[t+3]=this._w,e}fromBufferAttribute(e,t){return this._x=e.getX(t),this._y=e.getY(t),this._z=e.getZ(t),this._w=e.getW(t),this._onChangeCallback(),this}toJSON(){return this.toArray()}_onChange(e){return this._onChangeCallback=e,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._w}}class X{constructor(e=0,t=0,n=0){X.prototype.isVector3=!0,this.x=e,this.y=t,this.z=n}set(e,t,n){return n===void 0&&(n=this.z),this.x=e,this.y=t,this.z=n,this}setScalar(e){return this.x=e,this.y=e,this.z=e,this}setX(e){return this.x=e,this}setY(e){return this.y=e,this}setZ(e){return this.z=e,this}setComponent(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;case 2:this.z=t;break;default:throw new Error("index is out of range: "+e)}return this}getComponent(e){switch(e){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("index is out of range: "+e)}}clone(){return new this.constructor(this.x,this.y,this.z)}copy(e){return this.x=e.x,this.y=e.y,this.z=e.z,this}add(e){return this.x+=e.x,this.y+=e.y,this.z+=e.z,this}addScalar(e){return this.x+=e,this.y+=e,this.z+=e,this}addVectors(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this.z=e.z+t.z,this}addScaledVector(e,t){return this.x+=e.x*t,this.y+=e.y*t,this.z+=e.z*t,this}sub(e){return this.x-=e.x,this.y-=e.y,this.z-=e.z,this}subScalar(e){return this.x-=e,this.y-=e,this.z-=e,this}subVectors(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this.z=e.z-t.z,this}multiply(e){return this.x*=e.x,this.y*=e.y,this.z*=e.z,this}multiplyScalar(e){return this.x*=e,this.y*=e,this.z*=e,this}multiplyVectors(e,t){return this.x=e.x*t.x,this.y=e.y*t.y,this.z=e.z*t.z,this}applyEuler(e){return this.applyQuaternion(sf.setFromEuler(e))}applyAxisAngle(e,t){return this.applyQuaternion(sf.setFromAxisAngle(e,t))}applyMatrix3(e){const t=this.x,n=this.y,i=this.z,s=e.elements;return this.x=s[0]*t+s[3]*n+s[6]*i,this.y=s[1]*t+s[4]*n+s[7]*i,this.z=s[2]*t+s[5]*n+s[8]*i,this}applyNormalMatrix(e){return this.applyMatrix3(e).normalize()}applyMatrix4(e){const t=this.x,n=this.y,i=this.z,s=e.elements,a=1/(s[3]*t+s[7]*n+s[11]*i+s[15]);return this.x=(s[0]*t+s[4]*n+s[8]*i+s[12])*a,this.y=(s[1]*t+s[5]*n+s[9]*i+s[13])*a,this.z=(s[2]*t+s[6]*n+s[10]*i+s[14])*a,this}applyQuaternion(e){const t=this.x,n=this.y,i=this.z,s=e.x,a=e.y,o=e.z,l=e.w,c=2*(a*i-o*n),u=2*(o*t-s*i),h=2*(s*n-a*t);return this.x=t+l*c+a*h-o*u,this.y=n+l*u+o*c-s*h,this.z=i+l*h+s*u-a*c,this}project(e){return this.applyMatrix4(e.matrixWorldInverse).applyMatrix4(e.projectionMatrix)}unproject(e){return this.applyMatrix4(e.projectionMatrixInverse).applyMatrix4(e.matrixWorld)}transformDirection(e){const t=this.x,n=this.y,i=this.z,s=e.elements;return this.x=s[0]*t+s[4]*n+s[8]*i,this.y=s[1]*t+s[5]*n+s[9]*i,this.z=s[2]*t+s[6]*n+s[10]*i,this.normalize()}divide(e){return this.x/=e.x,this.y/=e.y,this.z/=e.z,this}divideScalar(e){return this.multiplyScalar(1/e)}min(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this.z=Math.min(this.z,e.z),this}max(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this.z=Math.max(this.z,e.z),this}clamp(e,t){return this.x=st(this.x,e.x,t.x),this.y=st(this.y,e.y,t.y),this.z=st(this.z,e.z,t.z),this}clampScalar(e,t){return this.x=st(this.x,e,t),this.y=st(this.y,e,t),this.z=st(this.z,e,t),this}clampLength(e,t){const n=this.length();return this.divideScalar(n||1).multiplyScalar(st(n,e,t))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this}dot(e){return this.x*e.x+this.y*e.y+this.z*e.z}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)}normalize(){return this.divideScalar(this.length()||1)}setLength(e){return this.normalize().multiplyScalar(e)}lerp(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this.z+=(e.z-this.z)*t,this}lerpVectors(e,t,n){return this.x=e.x+(t.x-e.x)*n,this.y=e.y+(t.y-e.y)*n,this.z=e.z+(t.z-e.z)*n,this}cross(e){return this.crossVectors(this,e)}crossVectors(e,t){const n=e.x,i=e.y,s=e.z,a=t.x,o=t.y,l=t.z;return this.x=i*l-s*o,this.y=s*a-n*l,this.z=n*o-i*a,this}projectOnVector(e){const t=e.lengthSq();if(t===0)return this.set(0,0,0);const n=e.dot(this)/t;return this.copy(e).multiplyScalar(n)}projectOnPlane(e){return ml.copy(this).projectOnVector(e),this.sub(ml)}reflect(e){return this.sub(ml.copy(e).multiplyScalar(2*this.dot(e)))}angleTo(e){const t=Math.sqrt(this.lengthSq()*e.lengthSq());if(t===0)return Math.PI/2;const n=this.dot(e)/t;return Math.acos(st(n,-1,1))}distanceTo(e){return Math.sqrt(this.distanceToSquared(e))}distanceToSquared(e){const t=this.x-e.x,n=this.y-e.y,i=this.z-e.z;return t*t+n*n+i*i}manhattanDistanceTo(e){return Math.abs(this.x-e.x)+Math.abs(this.y-e.y)+Math.abs(this.z-e.z)}setFromSpherical(e){return this.setFromSphericalCoords(e.radius,e.phi,e.theta)}setFromSphericalCoords(e,t,n){const i=Math.sin(t)*e;return this.x=i*Math.sin(n),this.y=Math.cos(t)*e,this.z=i*Math.cos(n),this}setFromCylindrical(e){return this.setFromCylindricalCoords(e.radius,e.theta,e.y)}setFromCylindricalCoords(e,t,n){return this.x=e*Math.sin(t),this.y=n,this.z=e*Math.cos(t),this}setFromMatrixPosition(e){const t=e.elements;return this.x=t[12],this.y=t[13],this.z=t[14],this}setFromMatrixScale(e){const t=this.setFromMatrixColumn(e,0).length(),n=this.setFromMatrixColumn(e,1).length(),i=this.setFromMatrixColumn(e,2).length();return this.x=t,this.y=n,this.z=i,this}setFromMatrixColumn(e,t){return this.fromArray(e.elements,t*4)}setFromMatrix3Column(e,t){return this.fromArray(e.elements,t*3)}setFromEuler(e){return this.x=e._x,this.y=e._y,this.z=e._z,this}setFromColor(e){return this.x=e.r,this.y=e.g,this.z=e.b,this}equals(e){return e.x===this.x&&e.y===this.y&&e.z===this.z}fromArray(e,t=0){return this.x=e[t],this.y=e[t+1],this.z=e[t+2],this}toArray(e=[],t=0){return e[t]=this.x,e[t+1]=this.y,e[t+2]=this.z,e}fromBufferAttribute(e,t){return this.x=e.getX(t),this.y=e.getY(t),this.z=e.getZ(t),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this}randomDirection(){const e=Math.random()*Math.PI*2,t=Math.random()*2-1,n=Math.sqrt(1-t*t);return this.x=n*Math.cos(e),this.y=t,this.z=n*Math.sin(e),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z}}const ml=new X,sf=new Ia;class Ua{constructor(e=new X(1/0,1/0,1/0),t=new X(-1/0,-1/0,-1/0)){this.isBox3=!0,this.min=e,this.max=t}set(e,t){return this.min.copy(e),this.max.copy(t),this}setFromArray(e){this.makeEmpty();for(let t=0,n=e.length;t<n;t+=3)this.expandByPoint(si.fromArray(e,t));return this}setFromBufferAttribute(e){this.makeEmpty();for(let t=0,n=e.count;t<n;t++)this.expandByPoint(si.fromBufferAttribute(e,t));return this}setFromPoints(e){this.makeEmpty();for(let t=0,n=e.length;t<n;t++)this.expandByPoint(e[t]);return this}setFromCenterAndSize(e,t){const n=si.copy(t).multiplyScalar(.5);return this.min.copy(e).sub(n),this.max.copy(e).add(n),this}setFromObject(e,t=!1){return this.makeEmpty(),this.expandByObject(e,t)}clone(){return new this.constructor().copy(this)}copy(e){return this.min.copy(e.min),this.max.copy(e.max),this}makeEmpty(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this}isEmpty(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z}getCenter(e){return this.isEmpty()?e.set(0,0,0):e.addVectors(this.min,this.max).multiplyScalar(.5)}getSize(e){return this.isEmpty()?e.set(0,0,0):e.subVectors(this.max,this.min)}expandByPoint(e){return this.min.min(e),this.max.max(e),this}expandByVector(e){return this.min.sub(e),this.max.add(e),this}expandByScalar(e){return this.min.addScalar(-e),this.max.addScalar(e),this}expandByObject(e,t=!1){e.updateWorldMatrix(!1,!1);const n=e.geometry;if(n!==void 0){const s=n.getAttribute("position");if(t===!0&&s!==void 0&&e.isInstancedMesh!==!0)for(let a=0,o=s.count;a<o;a++)e.isMesh===!0?e.getVertexPosition(a,si):si.fromBufferAttribute(s,a),si.applyMatrix4(e.matrixWorld),this.expandByPoint(si);else e.boundingBox!==void 0?(e.boundingBox===null&&e.computeBoundingBox(),za.copy(e.boundingBox)):(n.boundingBox===null&&n.computeBoundingBox(),za.copy(n.boundingBox)),za.applyMatrix4(e.matrixWorld),this.union(za)}const i=e.children;for(let s=0,a=i.length;s<a;s++)this.expandByObject(i[s],t);return this}containsPoint(e){return e.x>=this.min.x&&e.x<=this.max.x&&e.y>=this.min.y&&e.y<=this.max.y&&e.z>=this.min.z&&e.z<=this.max.z}containsBox(e){return this.min.x<=e.min.x&&e.max.x<=this.max.x&&this.min.y<=e.min.y&&e.max.y<=this.max.y&&this.min.z<=e.min.z&&e.max.z<=this.max.z}getParameter(e,t){return t.set((e.x-this.min.x)/(this.max.x-this.min.x),(e.y-this.min.y)/(this.max.y-this.min.y),(e.z-this.min.z)/(this.max.z-this.min.z))}intersectsBox(e){return e.max.x>=this.min.x&&e.min.x<=this.max.x&&e.max.y>=this.min.y&&e.min.y<=this.max.y&&e.max.z>=this.min.z&&e.min.z<=this.max.z}intersectsSphere(e){return this.clampPoint(e.center,si),si.distanceToSquared(e.center)<=e.radius*e.radius}intersectsPlane(e){let t,n;return e.normal.x>0?(t=e.normal.x*this.min.x,n=e.normal.x*this.max.x):(t=e.normal.x*this.max.x,n=e.normal.x*this.min.x),e.normal.y>0?(t+=e.normal.y*this.min.y,n+=e.normal.y*this.max.y):(t+=e.normal.y*this.max.y,n+=e.normal.y*this.min.y),e.normal.z>0?(t+=e.normal.z*this.min.z,n+=e.normal.z*this.max.z):(t+=e.normal.z*this.max.z,n+=e.normal.z*this.min.z),t<=-e.constant&&n>=-e.constant}intersectsTriangle(e){if(this.isEmpty())return!1;this.getCenter(qs),ka.subVectors(this.max,qs),Zr.subVectors(e.a,qs),jr.subVectors(e.b,qs),Jr.subVectors(e.c,qs),Gi.subVectors(jr,Zr),Wi.subVectors(Jr,jr),mr.subVectors(Zr,Jr);let t=[0,-Gi.z,Gi.y,0,-Wi.z,Wi.y,0,-mr.z,mr.y,Gi.z,0,-Gi.x,Wi.z,0,-Wi.x,mr.z,0,-mr.x,-Gi.y,Gi.x,0,-Wi.y,Wi.x,0,-mr.y,mr.x,0];return!_l(t,Zr,jr,Jr,ka)||(t=[1,0,0,0,1,0,0,0,1],!_l(t,Zr,jr,Jr,ka))?!1:(Ha.crossVectors(Gi,Wi),t=[Ha.x,Ha.y,Ha.z],_l(t,Zr,jr,Jr,ka))}clampPoint(e,t){return t.copy(e).clamp(this.min,this.max)}distanceToPoint(e){return this.clampPoint(e,si).distanceTo(e)}getBoundingSphere(e){return this.isEmpty()?e.makeEmpty():(this.getCenter(e.center),e.radius=this.getSize(si).length()*.5),e}intersect(e){return this.min.max(e.min),this.max.min(e.max),this.isEmpty()&&this.makeEmpty(),this}union(e){return this.min.min(e.min),this.max.max(e.max),this}applyMatrix4(e){return this.isEmpty()?this:(yi[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(e),yi[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(e),yi[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(e),yi[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(e),yi[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(e),yi[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(e),yi[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(e),yi[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(e),this.setFromPoints(yi),this)}translate(e){return this.min.add(e),this.max.add(e),this}equals(e){return e.min.equals(this.min)&&e.max.equals(this.max)}}const yi=[new X,new X,new X,new X,new X,new X,new X,new X],si=new X,za=new Ua,Zr=new X,jr=new X,Jr=new X,Gi=new X,Wi=new X,mr=new X,qs=new X,ka=new X,Ha=new X,_r=new X;function _l(r,e,t,n,i){for(let s=0,a=r.length-3;s<=a;s+=3){_r.fromArray(r,s);const o=i.x*Math.abs(_r.x)+i.y*Math.abs(_r.y)+i.z*Math.abs(_r.z),l=e.dot(_r),c=t.dot(_r),u=n.dot(_r);if(Math.max(-Math.max(l,c,u),Math.min(l,c,u))>o)return!1}return!0}const Nm=new Ua,Ys=new X,gl=new X;class Na{constructor(e=new X,t=-1){this.isSphere=!0,this.center=e,this.radius=t}set(e,t){return this.center.copy(e),this.radius=t,this}setFromPoints(e,t){const n=this.center;t!==void 0?n.copy(t):Nm.setFromPoints(e).getCenter(n);let i=0;for(let s=0,a=e.length;s<a;s++)i=Math.max(i,n.distanceToSquared(e[s]));return this.radius=Math.sqrt(i),this}copy(e){return this.center.copy(e.center),this.radius=e.radius,this}isEmpty(){return this.radius<0}makeEmpty(){return this.center.set(0,0,0),this.radius=-1,this}containsPoint(e){return e.distanceToSquared(this.center)<=this.radius*this.radius}distanceToPoint(e){return e.distanceTo(this.center)-this.radius}intersectsSphere(e){const t=this.radius+e.radius;return e.center.distanceToSquared(this.center)<=t*t}intersectsBox(e){return e.intersectsSphere(this)}intersectsPlane(e){return Math.abs(e.distanceToPoint(this.center))<=this.radius}clampPoint(e,t){const n=this.center.distanceToSquared(e);return t.copy(e),n>this.radius*this.radius&&(t.sub(this.center).normalize(),t.multiplyScalar(this.radius).add(this.center)),t}getBoundingBox(e){return this.isEmpty()?(e.makeEmpty(),e):(e.set(this.center,this.center),e.expandByScalar(this.radius),e)}applyMatrix4(e){return this.center.applyMatrix4(e),this.radius=this.radius*e.getMaxScaleOnAxis(),this}translate(e){return this.center.add(e),this}expandByPoint(e){if(this.isEmpty())return this.center.copy(e),this.radius=0,this;Ys.subVectors(e,this.center);const t=Ys.lengthSq();if(t>this.radius*this.radius){const n=Math.sqrt(t),i=(n-this.radius)*.5;this.center.addScaledVector(Ys,i/n),this.radius+=i}return this}union(e){return e.isEmpty()?this:this.isEmpty()?(this.copy(e),this):(this.center.equals(e.center)===!0?this.radius=Math.max(this.radius,e.radius):(gl.subVectors(e.center,this.center).setLength(e.radius),this.expandByPoint(Ys.copy(e.center).add(gl)),this.expandByPoint(Ys.copy(e.center).sub(gl))),this)}equals(e){return e.center.equals(this.center)&&e.radius===this.radius}clone(){return new this.constructor().copy(this)}}const Ei=new X,vl=new X,Va=new X,Xi=new X,xl=new X,Ga=new X,Ml=new X;class Su{constructor(e=new X,t=new X(0,0,-1)){this.origin=e,this.direction=t}set(e,t){return this.origin.copy(e),this.direction.copy(t),this}copy(e){return this.origin.copy(e.origin),this.direction.copy(e.direction),this}at(e,t){return t.copy(this.origin).addScaledVector(this.direction,e)}lookAt(e){return this.direction.copy(e).sub(this.origin).normalize(),this}recast(e){return this.origin.copy(this.at(e,Ei)),this}closestPointToPoint(e,t){t.subVectors(e,this.origin);const n=t.dot(this.direction);return n<0?t.copy(this.origin):t.copy(this.origin).addScaledVector(this.direction,n)}distanceToPoint(e){return Math.sqrt(this.distanceSqToPoint(e))}distanceSqToPoint(e){const t=Ei.subVectors(e,this.origin).dot(this.direction);return t<0?this.origin.distanceToSquared(e):(Ei.copy(this.origin).addScaledVector(this.direction,t),Ei.distanceToSquared(e))}distanceSqToSegment(e,t,n,i){vl.copy(e).add(t).multiplyScalar(.5),Va.copy(t).sub(e).normalize(),Xi.copy(this.origin).sub(vl);const s=e.distanceTo(t)*.5,a=-this.direction.dot(Va),o=Xi.dot(this.direction),l=-Xi.dot(Va),c=Xi.lengthSq(),u=Math.abs(1-a*a);let h,d,f,g;if(u>0)if(h=a*l-o,d=a*o-l,g=s*u,h>=0)if(d>=-g)if(d<=g){const _=1/u;h*=_,d*=_,f=h*(h+a*d+2*o)+d*(a*h+d+2*l)+c}else d=s,h=Math.max(0,-(a*d+o)),f=-h*h+d*(d+2*l)+c;else d=-s,h=Math.max(0,-(a*d+o)),f=-h*h+d*(d+2*l)+c;else d<=-g?(h=Math.max(0,-(-a*s+o)),d=h>0?-s:Math.min(Math.max(-s,-l),s),f=-h*h+d*(d+2*l)+c):d<=g?(h=0,d=Math.min(Math.max(-s,-l),s),f=d*(d+2*l)+c):(h=Math.max(0,-(a*s+o)),d=h>0?s:Math.min(Math.max(-s,-l),s),f=-h*h+d*(d+2*l)+c);else d=a>0?-s:s,h=Math.max(0,-(a*d+o)),f=-h*h+d*(d+2*l)+c;return n&&n.copy(this.origin).addScaledVector(this.direction,h),i&&i.copy(vl).addScaledVector(Va,d),f}intersectSphere(e,t){Ei.subVectors(e.center,this.origin);const n=Ei.dot(this.direction),i=Ei.dot(Ei)-n*n,s=e.radius*e.radius;if(i>s)return null;const a=Math.sqrt(s-i),o=n-a,l=n+a;return l<0?null:o<0?this.at(l,t):this.at(o,t)}intersectsSphere(e){return this.distanceSqToPoint(e.center)<=e.radius*e.radius}distanceToPlane(e){const t=e.normal.dot(this.direction);if(t===0)return e.distanceToPoint(this.origin)===0?0:null;const n=-(this.origin.dot(e.normal)+e.constant)/t;return n>=0?n:null}intersectPlane(e,t){const n=this.distanceToPlane(e);return n===null?null:this.at(n,t)}intersectsPlane(e){const t=e.distanceToPoint(this.origin);return t===0||e.normal.dot(this.direction)*t<0}intersectBox(e,t){let n,i,s,a,o,l;const c=1/this.direction.x,u=1/this.direction.y,h=1/this.direction.z,d=this.origin;return c>=0?(n=(e.min.x-d.x)*c,i=(e.max.x-d.x)*c):(n=(e.max.x-d.x)*c,i=(e.min.x-d.x)*c),u>=0?(s=(e.min.y-d.y)*u,a=(e.max.y-d.y)*u):(s=(e.max.y-d.y)*u,a=(e.min.y-d.y)*u),n>a||s>i||((s>n||isNaN(n))&&(n=s),(a<i||isNaN(i))&&(i=a),h>=0?(o=(e.min.z-d.z)*h,l=(e.max.z-d.z)*h):(o=(e.max.z-d.z)*h,l=(e.min.z-d.z)*h),n>l||o>i)||((o>n||n!==n)&&(n=o),(l<i||i!==i)&&(i=l),i<0)?null:this.at(n>=0?n:i,t)}intersectsBox(e){return this.intersectBox(e,Ei)!==null}intersectTriangle(e,t,n,i,s){xl.subVectors(t,e),Ga.subVectors(n,e),Ml.crossVectors(xl,Ga);let a=this.direction.dot(Ml),o;if(a>0){if(i)return null;o=1}else if(a<0)o=-1,a=-a;else return null;Xi.subVectors(this.origin,e);const l=o*this.direction.dot(Ga.crossVectors(Xi,Ga));if(l<0)return null;const c=o*this.direction.dot(xl.cross(Xi));if(c<0||l+c>a)return null;const u=-o*Xi.dot(Ml);return u<0?null:this.at(u/a,s)}applyMatrix4(e){return this.origin.applyMatrix4(e),this.direction.transformDirection(e),this}equals(e){return e.origin.equals(this.origin)&&e.direction.equals(this.direction)}clone(){return new this.constructor().copy(this)}}class Lt{constructor(e,t,n,i,s,a,o,l,c,u,h,d,f,g,_,m){Lt.prototype.isMatrix4=!0,this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],e!==void 0&&this.set(e,t,n,i,s,a,o,l,c,u,h,d,f,g,_,m)}set(e,t,n,i,s,a,o,l,c,u,h,d,f,g,_,m){const p=this.elements;return p[0]=e,p[4]=t,p[8]=n,p[12]=i,p[1]=s,p[5]=a,p[9]=o,p[13]=l,p[2]=c,p[6]=u,p[10]=h,p[14]=d,p[3]=f,p[7]=g,p[11]=_,p[15]=m,this}identity(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this}clone(){return new Lt().fromArray(this.elements)}copy(e){const t=this.elements,n=e.elements;return t[0]=n[0],t[1]=n[1],t[2]=n[2],t[3]=n[3],t[4]=n[4],t[5]=n[5],t[6]=n[6],t[7]=n[7],t[8]=n[8],t[9]=n[9],t[10]=n[10],t[11]=n[11],t[12]=n[12],t[13]=n[13],t[14]=n[14],t[15]=n[15],this}copyPosition(e){const t=this.elements,n=e.elements;return t[12]=n[12],t[13]=n[13],t[14]=n[14],this}setFromMatrix3(e){const t=e.elements;return this.set(t[0],t[3],t[6],0,t[1],t[4],t[7],0,t[2],t[5],t[8],0,0,0,0,1),this}extractBasis(e,t,n){return e.setFromMatrixColumn(this,0),t.setFromMatrixColumn(this,1),n.setFromMatrixColumn(this,2),this}makeBasis(e,t,n){return this.set(e.x,t.x,n.x,0,e.y,t.y,n.y,0,e.z,t.z,n.z,0,0,0,0,1),this}extractRotation(e){const t=this.elements,n=e.elements,i=1/Qr.setFromMatrixColumn(e,0).length(),s=1/Qr.setFromMatrixColumn(e,1).length(),a=1/Qr.setFromMatrixColumn(e,2).length();return t[0]=n[0]*i,t[1]=n[1]*i,t[2]=n[2]*i,t[3]=0,t[4]=n[4]*s,t[5]=n[5]*s,t[6]=n[6]*s,t[7]=0,t[8]=n[8]*a,t[9]=n[9]*a,t[10]=n[10]*a,t[11]=0,t[12]=0,t[13]=0,t[14]=0,t[15]=1,this}makeRotationFromEuler(e){const t=this.elements,n=e.x,i=e.y,s=e.z,a=Math.cos(n),o=Math.sin(n),l=Math.cos(i),c=Math.sin(i),u=Math.cos(s),h=Math.sin(s);if(e.order==="XYZ"){const d=a*u,f=a*h,g=o*u,_=o*h;t[0]=l*u,t[4]=-l*h,t[8]=c,t[1]=f+g*c,t[5]=d-_*c,t[9]=-o*l,t[2]=_-d*c,t[6]=g+f*c,t[10]=a*l}else if(e.order==="YXZ"){const d=l*u,f=l*h,g=c*u,_=c*h;t[0]=d+_*o,t[4]=g*o-f,t[8]=a*c,t[1]=a*h,t[5]=a*u,t[9]=-o,t[2]=f*o-g,t[6]=_+d*o,t[10]=a*l}else if(e.order==="ZXY"){const d=l*u,f=l*h,g=c*u,_=c*h;t[0]=d-_*o,t[4]=-a*h,t[8]=g+f*o,t[1]=f+g*o,t[5]=a*u,t[9]=_-d*o,t[2]=-a*c,t[6]=o,t[10]=a*l}else if(e.order==="ZYX"){const d=a*u,f=a*h,g=o*u,_=o*h;t[0]=l*u,t[4]=g*c-f,t[8]=d*c+_,t[1]=l*h,t[5]=_*c+d,t[9]=f*c-g,t[2]=-c,t[6]=o*l,t[10]=a*l}else if(e.order==="YZX"){const d=a*l,f=a*c,g=o*l,_=o*c;t[0]=l*u,t[4]=_-d*h,t[8]=g*h+f,t[1]=h,t[5]=a*u,t[9]=-o*u,t[2]=-c*u,t[6]=f*h+g,t[10]=d-_*h}else if(e.order==="XZY"){const d=a*l,f=a*c,g=o*l,_=o*c;t[0]=l*u,t[4]=-h,t[8]=c*u,t[1]=d*h+_,t[5]=a*u,t[9]=f*h-g,t[2]=g*h-f,t[6]=o*u,t[10]=_*h+d}return t[3]=0,t[7]=0,t[11]=0,t[12]=0,t[13]=0,t[14]=0,t[15]=1,this}makeRotationFromQuaternion(e){return this.compose(Fm,e,Om)}lookAt(e,t,n){const i=this.elements;return In.subVectors(e,t),In.lengthSq()===0&&(In.z=1),In.normalize(),qi.crossVectors(n,In),qi.lengthSq()===0&&(Math.abs(n.z)===1?In.x+=1e-4:In.z+=1e-4,In.normalize(),qi.crossVectors(n,In)),qi.normalize(),Wa.crossVectors(In,qi),i[0]=qi.x,i[4]=Wa.x,i[8]=In.x,i[1]=qi.y,i[5]=Wa.y,i[9]=In.y,i[2]=qi.z,i[6]=Wa.z,i[10]=In.z,this}multiply(e){return this.multiplyMatrices(this,e)}premultiply(e){return this.multiplyMatrices(e,this)}multiplyMatrices(e,t){const n=e.elements,i=t.elements,s=this.elements,a=n[0],o=n[4],l=n[8],c=n[12],u=n[1],h=n[5],d=n[9],f=n[13],g=n[2],_=n[6],m=n[10],p=n[14],T=n[3],E=n[7],x=n[11],R=n[15],w=i[0],b=i[4],C=i[8],M=i[12],v=i[1],P=i[5],U=i[9],O=i[13],G=i[2],Y=i[6],H=i[10],q=i[14],k=i[3],ne=i[7],D=i[11],ue=i[15];return s[0]=a*w+o*v+l*G+c*k,s[4]=a*b+o*P+l*Y+c*ne,s[8]=a*C+o*U+l*H+c*D,s[12]=a*M+o*O+l*q+c*ue,s[1]=u*w+h*v+d*G+f*k,s[5]=u*b+h*P+d*Y+f*ne,s[9]=u*C+h*U+d*H+f*D,s[13]=u*M+h*O+d*q+f*ue,s[2]=g*w+_*v+m*G+p*k,s[6]=g*b+_*P+m*Y+p*ne,s[10]=g*C+_*U+m*H+p*D,s[14]=g*M+_*O+m*q+p*ue,s[3]=T*w+E*v+x*G+R*k,s[7]=T*b+E*P+x*Y+R*ne,s[11]=T*C+E*U+x*H+R*D,s[15]=T*M+E*O+x*q+R*ue,this}multiplyScalar(e){const t=this.elements;return t[0]*=e,t[4]*=e,t[8]*=e,t[12]*=e,t[1]*=e,t[5]*=e,t[9]*=e,t[13]*=e,t[2]*=e,t[6]*=e,t[10]*=e,t[14]*=e,t[3]*=e,t[7]*=e,t[11]*=e,t[15]*=e,this}determinant(){const e=this.elements,t=e[0],n=e[4],i=e[8],s=e[12],a=e[1],o=e[5],l=e[9],c=e[13],u=e[2],h=e[6],d=e[10],f=e[14],g=e[3],_=e[7],m=e[11],p=e[15];return g*(+s*l*h-i*c*h-s*o*d+n*c*d+i*o*f-n*l*f)+_*(+t*l*f-t*c*d+s*a*d-i*a*f+i*c*u-s*l*u)+m*(+t*c*h-t*o*f-s*a*h+n*a*f+s*o*u-n*c*u)+p*(-i*o*u-t*l*h+t*o*d+i*a*h-n*a*d+n*l*u)}transpose(){const e=this.elements;let t;return t=e[1],e[1]=e[4],e[4]=t,t=e[2],e[2]=e[8],e[8]=t,t=e[6],e[6]=e[9],e[9]=t,t=e[3],e[3]=e[12],e[12]=t,t=e[7],e[7]=e[13],e[13]=t,t=e[11],e[11]=e[14],e[14]=t,this}setPosition(e,t,n){const i=this.elements;return e.isVector3?(i[12]=e.x,i[13]=e.y,i[14]=e.z):(i[12]=e,i[13]=t,i[14]=n),this}invert(){const e=this.elements,t=e[0],n=e[1],i=e[2],s=e[3],a=e[4],o=e[5],l=e[6],c=e[7],u=e[8],h=e[9],d=e[10],f=e[11],g=e[12],_=e[13],m=e[14],p=e[15],T=h*m*c-_*d*c+_*l*f-o*m*f-h*l*p+o*d*p,E=g*d*c-u*m*c-g*l*f+a*m*f+u*l*p-a*d*p,x=u*_*c-g*h*c+g*o*f-a*_*f-u*o*p+a*h*p,R=g*h*l-u*_*l-g*o*d+a*_*d+u*o*m-a*h*m,w=t*T+n*E+i*x+s*R;if(w===0)return this.set(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);const b=1/w;return e[0]=T*b,e[1]=(_*d*s-h*m*s-_*i*f+n*m*f+h*i*p-n*d*p)*b,e[2]=(o*m*s-_*l*s+_*i*c-n*m*c-o*i*p+n*l*p)*b,e[3]=(h*l*s-o*d*s-h*i*c+n*d*c+o*i*f-n*l*f)*b,e[4]=E*b,e[5]=(u*m*s-g*d*s+g*i*f-t*m*f-u*i*p+t*d*p)*b,e[6]=(g*l*s-a*m*s-g*i*c+t*m*c+a*i*p-t*l*p)*b,e[7]=(a*d*s-u*l*s+u*i*c-t*d*c-a*i*f+t*l*f)*b,e[8]=x*b,e[9]=(g*h*s-u*_*s-g*n*f+t*_*f+u*n*p-t*h*p)*b,e[10]=(a*_*s-g*o*s+g*n*c-t*_*c-a*n*p+t*o*p)*b,e[11]=(u*o*s-a*h*s-u*n*c+t*h*c+a*n*f-t*o*f)*b,e[12]=R*b,e[13]=(u*_*i-g*h*i+g*n*d-t*_*d-u*n*m+t*h*m)*b,e[14]=(g*o*i-a*_*i-g*n*l+t*_*l+a*n*m-t*o*m)*b,e[15]=(a*h*i-u*o*i+u*n*l-t*h*l-a*n*d+t*o*d)*b,this}scale(e){const t=this.elements,n=e.x,i=e.y,s=e.z;return t[0]*=n,t[4]*=i,t[8]*=s,t[1]*=n,t[5]*=i,t[9]*=s,t[2]*=n,t[6]*=i,t[10]*=s,t[3]*=n,t[7]*=i,t[11]*=s,this}getMaxScaleOnAxis(){const e=this.elements,t=e[0]*e[0]+e[1]*e[1]+e[2]*e[2],n=e[4]*e[4]+e[5]*e[5]+e[6]*e[6],i=e[8]*e[8]+e[9]*e[9]+e[10]*e[10];return Math.sqrt(Math.max(t,n,i))}makeTranslation(e,t,n){return e.isVector3?this.set(1,0,0,e.x,0,1,0,e.y,0,0,1,e.z,0,0,0,1):this.set(1,0,0,e,0,1,0,t,0,0,1,n,0,0,0,1),this}makeRotationX(e){const t=Math.cos(e),n=Math.sin(e);return this.set(1,0,0,0,0,t,-n,0,0,n,t,0,0,0,0,1),this}makeRotationY(e){const t=Math.cos(e),n=Math.sin(e);return this.set(t,0,n,0,0,1,0,0,-n,0,t,0,0,0,0,1),this}makeRotationZ(e){const t=Math.cos(e),n=Math.sin(e);return this.set(t,-n,0,0,n,t,0,0,0,0,1,0,0,0,0,1),this}makeRotationAxis(e,t){const n=Math.cos(t),i=Math.sin(t),s=1-n,a=e.x,o=e.y,l=e.z,c=s*a,u=s*o;return this.set(c*a+n,c*o-i*l,c*l+i*o,0,c*o+i*l,u*o+n,u*l-i*a,0,c*l-i*o,u*l+i*a,s*l*l+n,0,0,0,0,1),this}makeScale(e,t,n){return this.set(e,0,0,0,0,t,0,0,0,0,n,0,0,0,0,1),this}makeShear(e,t,n,i,s,a){return this.set(1,n,s,0,e,1,a,0,t,i,1,0,0,0,0,1),this}compose(e,t,n){const i=this.elements,s=t._x,a=t._y,o=t._z,l=t._w,c=s+s,u=a+a,h=o+o,d=s*c,f=s*u,g=s*h,_=a*u,m=a*h,p=o*h,T=l*c,E=l*u,x=l*h,R=n.x,w=n.y,b=n.z;return i[0]=(1-(_+p))*R,i[1]=(f+x)*R,i[2]=(g-E)*R,i[3]=0,i[4]=(f-x)*w,i[5]=(1-(d+p))*w,i[6]=(m+T)*w,i[7]=0,i[8]=(g+E)*b,i[9]=(m-T)*b,i[10]=(1-(d+_))*b,i[11]=0,i[12]=e.x,i[13]=e.y,i[14]=e.z,i[15]=1,this}decompose(e,t,n){const i=this.elements;let s=Qr.set(i[0],i[1],i[2]).length();const a=Qr.set(i[4],i[5],i[6]).length(),o=Qr.set(i[8],i[9],i[10]).length();this.determinant()<0&&(s=-s),e.x=i[12],e.y=i[13],e.z=i[14],ai.copy(this);const c=1/s,u=1/a,h=1/o;return ai.elements[0]*=c,ai.elements[1]*=c,ai.elements[2]*=c,ai.elements[4]*=u,ai.elements[5]*=u,ai.elements[6]*=u,ai.elements[8]*=h,ai.elements[9]*=h,ai.elements[10]*=h,t.setFromRotationMatrix(ai),n.x=s,n.y=a,n.z=o,this}makePerspective(e,t,n,i,s,a,o=Ii){const l=this.elements,c=2*s/(t-e),u=2*s/(n-i),h=(t+e)/(t-e),d=(n+i)/(n-i);let f,g;if(o===Ii)f=-(a+s)/(a-s),g=-2*a*s/(a-s);else if(o===Ho)f=-a/(a-s),g=-a*s/(a-s);else throw new Error("THREE.Matrix4.makePerspective(): Invalid coordinate system: "+o);return l[0]=c,l[4]=0,l[8]=h,l[12]=0,l[1]=0,l[5]=u,l[9]=d,l[13]=0,l[2]=0,l[6]=0,l[10]=f,l[14]=g,l[3]=0,l[7]=0,l[11]=-1,l[15]=0,this}makeOrthographic(e,t,n,i,s,a,o=Ii){const l=this.elements,c=1/(t-e),u=1/(n-i),h=1/(a-s),d=(t+e)*c,f=(n+i)*u;let g,_;if(o===Ii)g=(a+s)*h,_=-2*h;else if(o===Ho)g=s*h,_=-1*h;else throw new Error("THREE.Matrix4.makeOrthographic(): Invalid coordinate system: "+o);return l[0]=2*c,l[4]=0,l[8]=0,l[12]=-d,l[1]=0,l[5]=2*u,l[9]=0,l[13]=-f,l[2]=0,l[6]=0,l[10]=_,l[14]=-g,l[3]=0,l[7]=0,l[11]=0,l[15]=1,this}equals(e){const t=this.elements,n=e.elements;for(let i=0;i<16;i++)if(t[i]!==n[i])return!1;return!0}fromArray(e,t=0){for(let n=0;n<16;n++)this.elements[n]=e[n+t];return this}toArray(e=[],t=0){const n=this.elements;return e[t]=n[0],e[t+1]=n[1],e[t+2]=n[2],e[t+3]=n[3],e[t+4]=n[4],e[t+5]=n[5],e[t+6]=n[6],e[t+7]=n[7],e[t+8]=n[8],e[t+9]=n[9],e[t+10]=n[10],e[t+11]=n[11],e[t+12]=n[12],e[t+13]=n[13],e[t+14]=n[14],e[t+15]=n[15],e}}const Qr=new X,ai=new Lt,Fm=new X(0,0,0),Om=new X(1,1,1),qi=new X,Wa=new X,In=new X,af=new Lt,of=new Ia;class ki{constructor(e=0,t=0,n=0,i=ki.DEFAULT_ORDER){this.isEuler=!0,this._x=e,this._y=t,this._z=n,this._order=i}get x(){return this._x}set x(e){this._x=e,this._onChangeCallback()}get y(){return this._y}set y(e){this._y=e,this._onChangeCallback()}get z(){return this._z}set z(e){this._z=e,this._onChangeCallback()}get order(){return this._order}set order(e){this._order=e,this._onChangeCallback()}set(e,t,n,i=this._order){return this._x=e,this._y=t,this._z=n,this._order=i,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._order)}copy(e){return this._x=e._x,this._y=e._y,this._z=e._z,this._order=e._order,this._onChangeCallback(),this}setFromRotationMatrix(e,t=this._order,n=!0){const i=e.elements,s=i[0],a=i[4],o=i[8],l=i[1],c=i[5],u=i[9],h=i[2],d=i[6],f=i[10];switch(t){case"XYZ":this._y=Math.asin(st(o,-1,1)),Math.abs(o)<.9999999?(this._x=Math.atan2(-u,f),this._z=Math.atan2(-a,s)):(this._x=Math.atan2(d,c),this._z=0);break;case"YXZ":this._x=Math.asin(-st(u,-1,1)),Math.abs(u)<.9999999?(this._y=Math.atan2(o,f),this._z=Math.atan2(l,c)):(this._y=Math.atan2(-h,s),this._z=0);break;case"ZXY":this._x=Math.asin(st(d,-1,1)),Math.abs(d)<.9999999?(this._y=Math.atan2(-h,f),this._z=Math.atan2(-a,c)):(this._y=0,this._z=Math.atan2(l,s));break;case"ZYX":this._y=Math.asin(-st(h,-1,1)),Math.abs(h)<.9999999?(this._x=Math.atan2(d,f),this._z=Math.atan2(l,s)):(this._x=0,this._z=Math.atan2(-a,c));break;case"YZX":this._z=Math.asin(st(l,-1,1)),Math.abs(l)<.9999999?(this._x=Math.atan2(-u,c),this._y=Math.atan2(-h,s)):(this._x=0,this._y=Math.atan2(o,f));break;case"XZY":this._z=Math.asin(-st(a,-1,1)),Math.abs(a)<.9999999?(this._x=Math.atan2(d,c),this._y=Math.atan2(o,s)):(this._x=Math.atan2(-u,f),this._y=0);break;default:console.warn("THREE.Euler: .setFromRotationMatrix() encountered an unknown order: "+t)}return this._order=t,n===!0&&this._onChangeCallback(),this}setFromQuaternion(e,t,n){return af.makeRotationFromQuaternion(e),this.setFromRotationMatrix(af,t,n)}setFromVector3(e,t=this._order){return this.set(e.x,e.y,e.z,t)}reorder(e){return of.setFromEuler(this),this.setFromQuaternion(of,e)}equals(e){return e._x===this._x&&e._y===this._y&&e._z===this._z&&e._order===this._order}fromArray(e){return this._x=e[0],this._y=e[1],this._z=e[2],e[3]!==void 0&&(this._order=e[3]),this._onChangeCallback(),this}toArray(e=[],t=0){return e[t]=this._x,e[t+1]=this._y,e[t+2]=this._z,e[t+3]=this._order,e}_onChange(e){return this._onChangeCallback=e,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._order}}ki.DEFAULT_ORDER="XYZ";class Zh{constructor(){this.mask=1}set(e){this.mask=(1<<e|0)>>>0}enable(e){this.mask|=1<<e|0}enableAll(){this.mask=-1}toggle(e){this.mask^=1<<e|0}disable(e){this.mask&=~(1<<e|0)}disableAll(){this.mask=0}test(e){return(this.mask&e.mask)!==0}isEnabled(e){return(this.mask&(1<<e|0))!==0}}let Bm=0;const lf=new X,es=new Ia,Ti=new Lt,Xa=new X,$s=new X,zm=new X,km=new Ia,cf=new X(1,0,0),uf=new X(0,1,0),ff=new X(0,0,1),hf={type:"added"},Hm={type:"removed"},ts={type:"childadded",child:null},Sl={type:"childremoved",child:null};class xn extends Hs{constructor(){super(),this.isObject3D=!0,Object.defineProperty(this,"id",{value:Bm++}),this.uuid=La(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=xn.DEFAULT_UP.clone();const e=new X,t=new ki,n=new Ia,i=new X(1,1,1);function s(){n.setFromEuler(t,!1)}function a(){t.setFromQuaternion(n,void 0,!1)}t._onChange(s),n._onChange(a),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:e},rotation:{configurable:!0,enumerable:!0,value:t},quaternion:{configurable:!0,enumerable:!0,value:n},scale:{configurable:!0,enumerable:!0,value:i},modelViewMatrix:{value:new Lt},normalMatrix:{value:new qe}}),this.matrix=new Lt,this.matrixWorld=new Lt,this.matrixAutoUpdate=xn.DEFAULT_MATRIX_AUTO_UPDATE,this.matrixWorldAutoUpdate=xn.DEFAULT_MATRIX_WORLD_AUTO_UPDATE,this.matrixWorldNeedsUpdate=!1,this.layers=new Zh,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.animations=[],this.userData={}}onBeforeShadow(){}onAfterShadow(){}onBeforeRender(){}onAfterRender(){}applyMatrix4(e){this.matrixAutoUpdate&&this.updateMatrix(),this.matrix.premultiply(e),this.matrix.decompose(this.position,this.quaternion,this.scale)}applyQuaternion(e){return this.quaternion.premultiply(e),this}setRotationFromAxisAngle(e,t){this.quaternion.setFromAxisAngle(e,t)}setRotationFromEuler(e){this.quaternion.setFromEuler(e,!0)}setRotationFromMatrix(e){this.quaternion.setFromRotationMatrix(e)}setRotationFromQuaternion(e){this.quaternion.copy(e)}rotateOnAxis(e,t){return es.setFromAxisAngle(e,t),this.quaternion.multiply(es),this}rotateOnWorldAxis(e,t){return es.setFromAxisAngle(e,t),this.quaternion.premultiply(es),this}rotateX(e){return this.rotateOnAxis(cf,e)}rotateY(e){return this.rotateOnAxis(uf,e)}rotateZ(e){return this.rotateOnAxis(ff,e)}translateOnAxis(e,t){return lf.copy(e).applyQuaternion(this.quaternion),this.position.add(lf.multiplyScalar(t)),this}translateX(e){return this.translateOnAxis(cf,e)}translateY(e){return this.translateOnAxis(uf,e)}translateZ(e){return this.translateOnAxis(ff,e)}localToWorld(e){return this.updateWorldMatrix(!0,!1),e.applyMatrix4(this.matrixWorld)}worldToLocal(e){return this.updateWorldMatrix(!0,!1),e.applyMatrix4(Ti.copy(this.matrixWorld).invert())}lookAt(e,t,n){e.isVector3?Xa.copy(e):Xa.set(e,t,n);const i=this.parent;this.updateWorldMatrix(!0,!1),$s.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?Ti.lookAt($s,Xa,this.up):Ti.lookAt(Xa,$s,this.up),this.quaternion.setFromRotationMatrix(Ti),i&&(Ti.extractRotation(i.matrixWorld),es.setFromRotationMatrix(Ti),this.quaternion.premultiply(es.invert()))}add(e){if(arguments.length>1){for(let t=0;t<arguments.length;t++)this.add(arguments[t]);return this}return e===this?(console.error("THREE.Object3D.add: object can't be added as a child of itself.",e),this):(e&&e.isObject3D?(e.removeFromParent(),e.parent=this,this.children.push(e),e.dispatchEvent(hf),ts.child=e,this.dispatchEvent(ts),ts.child=null):console.error("THREE.Object3D.add: object not an instance of THREE.Object3D.",e),this)}remove(e){if(arguments.length>1){for(let n=0;n<arguments.length;n++)this.remove(arguments[n]);return this}const t=this.children.indexOf(e);return t!==-1&&(e.parent=null,this.children.splice(t,1),e.dispatchEvent(Hm),Sl.child=e,this.dispatchEvent(Sl),Sl.child=null),this}removeFromParent(){const e=this.parent;return e!==null&&e.remove(this),this}clear(){return this.remove(...this.children)}attach(e){return this.updateWorldMatrix(!0,!1),Ti.copy(this.matrixWorld).invert(),e.parent!==null&&(e.parent.updateWorldMatrix(!0,!1),Ti.multiply(e.parent.matrixWorld)),e.applyMatrix4(Ti),e.removeFromParent(),e.parent=this,this.children.push(e),e.updateWorldMatrix(!1,!0),e.dispatchEvent(hf),ts.child=e,this.dispatchEvent(ts),ts.child=null,this}getObjectById(e){return this.getObjectByProperty("id",e)}getObjectByName(e){return this.getObjectByProperty("name",e)}getObjectByProperty(e,t){if(this[e]===t)return this;for(let n=0,i=this.children.length;n<i;n++){const a=this.children[n].getObjectByProperty(e,t);if(a!==void 0)return a}}getObjectsByProperty(e,t,n=[]){this[e]===t&&n.push(this);const i=this.children;for(let s=0,a=i.length;s<a;s++)i[s].getObjectsByProperty(e,t,n);return n}getWorldPosition(e){return this.updateWorldMatrix(!0,!1),e.setFromMatrixPosition(this.matrixWorld)}getWorldQuaternion(e){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose($s,e,zm),e}getWorldScale(e){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose($s,km,e),e}getWorldDirection(e){this.updateWorldMatrix(!0,!1);const t=this.matrixWorld.elements;return e.set(t[8],t[9],t[10]).normalize()}raycast(){}traverse(e){e(this);const t=this.children;for(let n=0,i=t.length;n<i;n++)t[n].traverse(e)}traverseVisible(e){if(this.visible===!1)return;e(this);const t=this.children;for(let n=0,i=t.length;n<i;n++)t[n].traverseVisible(e)}traverseAncestors(e){const t=this.parent;t!==null&&(e(t),t.traverseAncestors(e))}updateMatrix(){this.matrix.compose(this.position,this.quaternion,this.scale),this.matrixWorldNeedsUpdate=!0}updateMatrixWorld(e){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||e)&&(this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),this.matrixWorldNeedsUpdate=!1,e=!0);const t=this.children;for(let n=0,i=t.length;n<i;n++)t[n].updateMatrixWorld(e)}updateWorldMatrix(e,t){const n=this.parent;if(e===!0&&n!==null&&n.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),t===!0){const i=this.children;for(let s=0,a=i.length;s<a;s++)i[s].updateWorldMatrix(!1,!0)}}toJSON(e){const t=e===void 0||typeof e=="string",n={};t&&(e={geometries:{},materials:{},textures:{},images:{},shapes:{},skeletons:{},animations:{},nodes:{}},n.metadata={version:4.6,type:"Object",generator:"Object3D.toJSON"});const i={};i.uuid=this.uuid,i.type=this.type,this.name!==""&&(i.name=this.name),this.castShadow===!0&&(i.castShadow=!0),this.receiveShadow===!0&&(i.receiveShadow=!0),this.visible===!1&&(i.visible=!1),this.frustumCulled===!1&&(i.frustumCulled=!1),this.renderOrder!==0&&(i.renderOrder=this.renderOrder),Object.keys(this.userData).length>0&&(i.userData=this.userData),i.layers=this.layers.mask,i.matrix=this.matrix.toArray(),i.up=this.up.toArray(),this.matrixAutoUpdate===!1&&(i.matrixAutoUpdate=!1),this.isInstancedMesh&&(i.type="InstancedMesh",i.count=this.count,i.instanceMatrix=this.instanceMatrix.toJSON(),this.instanceColor!==null&&(i.instanceColor=this.instanceColor.toJSON())),this.isBatchedMesh&&(i.type="BatchedMesh",i.perObjectFrustumCulled=this.perObjectFrustumCulled,i.sortObjects=this.sortObjects,i.drawRanges=this._drawRanges,i.reservedRanges=this._reservedRanges,i.visibility=this._visibility,i.active=this._active,i.bounds=this._bounds.map(o=>({boxInitialized:o.boxInitialized,boxMin:o.box.min.toArray(),boxMax:o.box.max.toArray(),sphereInitialized:o.sphereInitialized,sphereRadius:o.sphere.radius,sphereCenter:o.sphere.center.toArray()})),i.maxInstanceCount=this._maxInstanceCount,i.maxVertexCount=this._maxVertexCount,i.maxIndexCount=this._maxIndexCount,i.geometryInitialized=this._geometryInitialized,i.geometryCount=this._geometryCount,i.matricesTexture=this._matricesTexture.toJSON(e),this._colorsTexture!==null&&(i.colorsTexture=this._colorsTexture.toJSON(e)),this.boundingSphere!==null&&(i.boundingSphere={center:i.boundingSphere.center.toArray(),radius:i.boundingSphere.radius}),this.boundingBox!==null&&(i.boundingBox={min:i.boundingBox.min.toArray(),max:i.boundingBox.max.toArray()}));function s(o,l){return o[l.uuid]===void 0&&(o[l.uuid]=l.toJSON(e)),l.uuid}if(this.isScene)this.background&&(this.background.isColor?i.background=this.background.toJSON():this.background.isTexture&&(i.background=this.background.toJSON(e).uuid)),this.environment&&this.environment.isTexture&&this.environment.isRenderTargetTexture!==!0&&(i.environment=this.environment.toJSON(e).uuid);else if(this.isMesh||this.isLine||this.isPoints){i.geometry=s(e.geometries,this.geometry);const o=this.geometry.parameters;if(o!==void 0&&o.shapes!==void 0){const l=o.shapes;if(Array.isArray(l))for(let c=0,u=l.length;c<u;c++){const h=l[c];s(e.shapes,h)}else s(e.shapes,l)}}if(this.isSkinnedMesh&&(i.bindMode=this.bindMode,i.bindMatrix=this.bindMatrix.toArray(),this.skeleton!==void 0&&(s(e.skeletons,this.skeleton),i.skeleton=this.skeleton.uuid)),this.material!==void 0)if(Array.isArray(this.material)){const o=[];for(let l=0,c=this.material.length;l<c;l++)o.push(s(e.materials,this.material[l]));i.material=o}else i.material=s(e.materials,this.material);if(this.children.length>0){i.children=[];for(let o=0;o<this.children.length;o++)i.children.push(this.children[o].toJSON(e).object)}if(this.animations.length>0){i.animations=[];for(let o=0;o<this.animations.length;o++){const l=this.animations[o];i.animations.push(s(e.animations,l))}}if(t){const o=a(e.geometries),l=a(e.materials),c=a(e.textures),u=a(e.images),h=a(e.shapes),d=a(e.skeletons),f=a(e.animations),g=a(e.nodes);o.length>0&&(n.geometries=o),l.length>0&&(n.materials=l),c.length>0&&(n.textures=c),u.length>0&&(n.images=u),h.length>0&&(n.shapes=h),d.length>0&&(n.skeletons=d),f.length>0&&(n.animations=f),g.length>0&&(n.nodes=g)}return n.object=i,n;function a(o){const l=[];for(const c in o){const u=o[c];delete u.metadata,l.push(u)}return l}}clone(e){return new this.constructor().copy(this,e)}copy(e,t=!0){if(this.name=e.name,this.up.copy(e.up),this.position.copy(e.position),this.rotation.order=e.rotation.order,this.quaternion.copy(e.quaternion),this.scale.copy(e.scale),this.matrix.copy(e.matrix),this.matrixWorld.copy(e.matrixWorld),this.matrixAutoUpdate=e.matrixAutoUpdate,this.matrixWorldAutoUpdate=e.matrixWorldAutoUpdate,this.matrixWorldNeedsUpdate=e.matrixWorldNeedsUpdate,this.layers.mask=e.layers.mask,this.visible=e.visible,this.castShadow=e.castShadow,this.receiveShadow=e.receiveShadow,this.frustumCulled=e.frustumCulled,this.renderOrder=e.renderOrder,this.animations=e.animations.slice(),this.userData=JSON.parse(JSON.stringify(e.userData)),t===!0)for(let n=0;n<e.children.length;n++){const i=e.children[n];this.add(i.clone())}return this}}xn.DEFAULT_UP=new X(0,1,0);xn.DEFAULT_MATRIX_AUTO_UPDATE=!0;xn.DEFAULT_MATRIX_WORLD_AUTO_UPDATE=!0;const oi=new X,bi=new X,yl=new X,Ai=new X,ns=new X,is=new X,df=new X,El=new X,Tl=new X,bl=new X,Al=new Nt,wl=new Nt,Rl=new Nt;class ci{constructor(e=new X,t=new X,n=new X){this.a=e,this.b=t,this.c=n}static getNormal(e,t,n,i){i.subVectors(n,t),oi.subVectors(e,t),i.cross(oi);const s=i.lengthSq();return s>0?i.multiplyScalar(1/Math.sqrt(s)):i.set(0,0,0)}static getBarycoord(e,t,n,i,s){oi.subVectors(i,t),bi.subVectors(n,t),yl.subVectors(e,t);const a=oi.dot(oi),o=oi.dot(bi),l=oi.dot(yl),c=bi.dot(bi),u=bi.dot(yl),h=a*c-o*o;if(h===0)return s.set(0,0,0),null;const d=1/h,f=(c*l-o*u)*d,g=(a*u-o*l)*d;return s.set(1-f-g,g,f)}static containsPoint(e,t,n,i){return this.getBarycoord(e,t,n,i,Ai)===null?!1:Ai.x>=0&&Ai.y>=0&&Ai.x+Ai.y<=1}static getInterpolation(e,t,n,i,s,a,o,l){return this.getBarycoord(e,t,n,i,Ai)===null?(l.x=0,l.y=0,"z"in l&&(l.z=0),"w"in l&&(l.w=0),null):(l.setScalar(0),l.addScaledVector(s,Ai.x),l.addScaledVector(a,Ai.y),l.addScaledVector(o,Ai.z),l)}static getInterpolatedAttribute(e,t,n,i,s,a){return Al.setScalar(0),wl.setScalar(0),Rl.setScalar(0),Al.fromBufferAttribute(e,t),wl.fromBufferAttribute(e,n),Rl.fromBufferAttribute(e,i),a.setScalar(0),a.addScaledVector(Al,s.x),a.addScaledVector(wl,s.y),a.addScaledVector(Rl,s.z),a}static isFrontFacing(e,t,n,i){return oi.subVectors(n,t),bi.subVectors(e,t),oi.cross(bi).dot(i)<0}set(e,t,n){return this.a.copy(e),this.b.copy(t),this.c.copy(n),this}setFromPointsAndIndices(e,t,n,i){return this.a.copy(e[t]),this.b.copy(e[n]),this.c.copy(e[i]),this}setFromAttributeAndIndices(e,t,n,i){return this.a.fromBufferAttribute(e,t),this.b.fromBufferAttribute(e,n),this.c.fromBufferAttribute(e,i),this}clone(){return new this.constructor().copy(this)}copy(e){return this.a.copy(e.a),this.b.copy(e.b),this.c.copy(e.c),this}getArea(){return oi.subVectors(this.c,this.b),bi.subVectors(this.a,this.b),oi.cross(bi).length()*.5}getMidpoint(e){return e.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)}getNormal(e){return ci.getNormal(this.a,this.b,this.c,e)}getPlane(e){return e.setFromCoplanarPoints(this.a,this.b,this.c)}getBarycoord(e,t){return ci.getBarycoord(e,this.a,this.b,this.c,t)}getInterpolation(e,t,n,i,s){return ci.getInterpolation(e,this.a,this.b,this.c,t,n,i,s)}containsPoint(e){return ci.containsPoint(e,this.a,this.b,this.c)}isFrontFacing(e){return ci.isFrontFacing(this.a,this.b,this.c,e)}intersectsBox(e){return e.intersectsTriangle(this)}closestPointToPoint(e,t){const n=this.a,i=this.b,s=this.c;let a,o;ns.subVectors(i,n),is.subVectors(s,n),El.subVectors(e,n);const l=ns.dot(El),c=is.dot(El);if(l<=0&&c<=0)return t.copy(n);Tl.subVectors(e,i);const u=ns.dot(Tl),h=is.dot(Tl);if(u>=0&&h<=u)return t.copy(i);const d=l*h-u*c;if(d<=0&&l>=0&&u<=0)return a=l/(l-u),t.copy(n).addScaledVector(ns,a);bl.subVectors(e,s);const f=ns.dot(bl),g=is.dot(bl);if(g>=0&&f<=g)return t.copy(s);const _=f*c-l*g;if(_<=0&&c>=0&&g<=0)return o=c/(c-g),t.copy(n).addScaledVector(is,o);const m=u*g-f*h;if(m<=0&&h-u>=0&&f-g>=0)return df.subVectors(s,i),o=(h-u)/(h-u+(f-g)),t.copy(i).addScaledVector(df,o);const p=1/(m+_+d);return a=_*p,o=d*p,t.copy(n).addScaledVector(ns,a).addScaledVector(is,o)}equals(e){return e.a.equals(this.a)&&e.b.equals(this.b)&&e.c.equals(this.c)}}const jh={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074},Yi={h:0,s:0,l:0},qa={h:0,s:0,l:0};function Cl(r,e,t){return t<0&&(t+=1),t>1&&(t-=1),t<1/6?r+(e-r)*6*t:t<1/2?e:t<2/3?r+(e-r)*6*(2/3-t):r}class nt{constructor(e,t,n){return this.isColor=!0,this.r=1,this.g=1,this.b=1,this.set(e,t,n)}set(e,t,n){if(t===void 0&&n===void 0){const i=e;i&&i.isColor?this.copy(i):typeof i=="number"?this.setHex(i):typeof i=="string"&&this.setStyle(i)}else this.setRGB(e,t,n);return this}setScalar(e){return this.r=e,this.g=e,this.b=e,this}setHex(e,t=jn){return e=Math.floor(e),this.r=(e>>16&255)/255,this.g=(e>>8&255)/255,this.b=(e&255)/255,ut.toWorkingColorSpace(this,t),this}setRGB(e,t,n,i=ut.workingColorSpace){return this.r=e,this.g=t,this.b=n,ut.toWorkingColorSpace(this,i),this}setHSL(e,t,n,i=ut.workingColorSpace){if(e=Tm(e,1),t=st(t,0,1),n=st(n,0,1),t===0)this.r=this.g=this.b=n;else{const s=n<=.5?n*(1+t):n+t-n*t,a=2*n-s;this.r=Cl(a,s,e+1/3),this.g=Cl(a,s,e),this.b=Cl(a,s,e-1/3)}return ut.toWorkingColorSpace(this,i),this}setStyle(e,t=jn){function n(s){s!==void 0&&parseFloat(s)<1&&console.warn("THREE.Color: Alpha component of "+e+" will be ignored.")}let i;if(i=/^(\w+)\(([^\)]*)\)/.exec(e)){let s;const a=i[1],o=i[2];switch(a){case"rgb":case"rgba":if(s=/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(o))return n(s[4]),this.setRGB(Math.min(255,parseInt(s[1],10))/255,Math.min(255,parseInt(s[2],10))/255,Math.min(255,parseInt(s[3],10))/255,t);if(s=/^\s*(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(o))return n(s[4]),this.setRGB(Math.min(100,parseInt(s[1],10))/100,Math.min(100,parseInt(s[2],10))/100,Math.min(100,parseInt(s[3],10))/100,t);break;case"hsl":case"hsla":if(s=/^\s*(\d*\.?\d+)\s*,\s*(\d*\.?\d+)\%\s*,\s*(\d*\.?\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(o))return n(s[4]),this.setHSL(parseFloat(s[1])/360,parseFloat(s[2])/100,parseFloat(s[3])/100,t);break;default:console.warn("THREE.Color: Unknown color model "+e)}}else if(i=/^\#([A-Fa-f\d]+)$/.exec(e)){const s=i[1],a=s.length;if(a===3)return this.setRGB(parseInt(s.charAt(0),16)/15,parseInt(s.charAt(1),16)/15,parseInt(s.charAt(2),16)/15,t);if(a===6)return this.setHex(parseInt(s,16),t);console.warn("THREE.Color: Invalid hex color "+e)}else if(e&&e.length>0)return this.setColorName(e,t);return this}setColorName(e,t=jn){const n=jh[e.toLowerCase()];return n!==void 0?this.setHex(n,t):console.warn("THREE.Color: Unknown color "+e),this}clone(){return new this.constructor(this.r,this.g,this.b)}copy(e){return this.r=e.r,this.g=e.g,this.b=e.b,this}copySRGBToLinear(e){return this.r=Fi(e.r),this.g=Fi(e.g),this.b=Fi(e.b),this}copyLinearToSRGB(e){return this.r=Ms(e.r),this.g=Ms(e.g),this.b=Ms(e.b),this}convertSRGBToLinear(){return this.copySRGBToLinear(this),this}convertLinearToSRGB(){return this.copyLinearToSRGB(this),this}getHex(e=jn){return ut.fromWorkingColorSpace(nn.copy(this),e),Math.round(st(nn.r*255,0,255))*65536+Math.round(st(nn.g*255,0,255))*256+Math.round(st(nn.b*255,0,255))}getHexString(e=jn){return("000000"+this.getHex(e).toString(16)).slice(-6)}getHSL(e,t=ut.workingColorSpace){ut.fromWorkingColorSpace(nn.copy(this),t);const n=nn.r,i=nn.g,s=nn.b,a=Math.max(n,i,s),o=Math.min(n,i,s);let l,c;const u=(o+a)/2;if(o===a)l=0,c=0;else{const h=a-o;switch(c=u<=.5?h/(a+o):h/(2-a-o),a){case n:l=(i-s)/h+(i<s?6:0);break;case i:l=(s-n)/h+2;break;case s:l=(n-i)/h+4;break}l/=6}return e.h=l,e.s=c,e.l=u,e}getRGB(e,t=ut.workingColorSpace){return ut.fromWorkingColorSpace(nn.copy(this),t),e.r=nn.r,e.g=nn.g,e.b=nn.b,e}getStyle(e=jn){ut.fromWorkingColorSpace(nn.copy(this),e);const t=nn.r,n=nn.g,i=nn.b;return e!==jn?`color(${e} ${t.toFixed(3)} ${n.toFixed(3)} ${i.toFixed(3)})`:`rgb(${Math.round(t*255)},${Math.round(n*255)},${Math.round(i*255)})`}offsetHSL(e,t,n){return this.getHSL(Yi),this.setHSL(Yi.h+e,Yi.s+t,Yi.l+n)}add(e){return this.r+=e.r,this.g+=e.g,this.b+=e.b,this}addColors(e,t){return this.r=e.r+t.r,this.g=e.g+t.g,this.b=e.b+t.b,this}addScalar(e){return this.r+=e,this.g+=e,this.b+=e,this}sub(e){return this.r=Math.max(0,this.r-e.r),this.g=Math.max(0,this.g-e.g),this.b=Math.max(0,this.b-e.b),this}multiply(e){return this.r*=e.r,this.g*=e.g,this.b*=e.b,this}multiplyScalar(e){return this.r*=e,this.g*=e,this.b*=e,this}lerp(e,t){return this.r+=(e.r-this.r)*t,this.g+=(e.g-this.g)*t,this.b+=(e.b-this.b)*t,this}lerpColors(e,t,n){return this.r=e.r+(t.r-e.r)*n,this.g=e.g+(t.g-e.g)*n,this.b=e.b+(t.b-e.b)*n,this}lerpHSL(e,t){this.getHSL(Yi),e.getHSL(qa);const n=hl(Yi.h,qa.h,t),i=hl(Yi.s,qa.s,t),s=hl(Yi.l,qa.l,t);return this.setHSL(n,i,s),this}setFromVector3(e){return this.r=e.x,this.g=e.y,this.b=e.z,this}applyMatrix3(e){const t=this.r,n=this.g,i=this.b,s=e.elements;return this.r=s[0]*t+s[3]*n+s[6]*i,this.g=s[1]*t+s[4]*n+s[7]*i,this.b=s[2]*t+s[5]*n+s[8]*i,this}equals(e){return e.r===this.r&&e.g===this.g&&e.b===this.b}fromArray(e,t=0){return this.r=e[t],this.g=e[t+1],this.b=e[t+2],this}toArray(e=[],t=0){return e[t]=this.r,e[t+1]=this.g,e[t+2]=this.b,e}fromBufferAttribute(e,t){return this.r=e.getX(t),this.g=e.getY(t),this.b=e.getZ(t),this}toJSON(){return this.getHex()}*[Symbol.iterator](){yield this.r,yield this.g,yield this.b}}const nn=new nt;nt.NAMES=jh;let Vm=0;class Vs extends Hs{constructor(){super(),this.isMaterial=!0,Object.defineProperty(this,"id",{value:Vm++}),this.uuid=La(),this.name="",this.type="Material",this.blending=vs,this.side=or,this.vertexColors=!1,this.opacity=1,this.transparent=!1,this.alphaHash=!1,this.blendSrc=nc,this.blendDst=ic,this.blendEquation=Rr,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.blendColor=new nt(0,0,0),this.blendAlpha=0,this.depthFunc=ws,this.depthTest=!0,this.depthWrite=!0,this.stencilWriteMask=255,this.stencilFunc=Ju,this.stencilRef=0,this.stencilFuncMask=255,this.stencilFail=$r,this.stencilZFail=$r,this.stencilZPass=$r,this.stencilWrite=!1,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaToCoverage=!1,this.premultipliedAlpha=!1,this.forceSinglePass=!1,this.visible=!0,this.toneMapped=!0,this.userData={},this.version=0,this._alphaTest=0}get alphaTest(){return this._alphaTest}set alphaTest(e){this._alphaTest>0!=e>0&&this.version++,this._alphaTest=e}onBeforeRender(){}onBeforeCompile(){}customProgramCacheKey(){return this.onBeforeCompile.toString()}setValues(e){if(e!==void 0)for(const t in e){const n=e[t];if(n===void 0){console.warn(`THREE.Material: parameter '${t}' has value of undefined.`);continue}const i=this[t];if(i===void 0){console.warn(`THREE.Material: '${t}' is not a property of THREE.${this.type}.`);continue}i&&i.isColor?i.set(n):i&&i.isVector3&&n&&n.isVector3?i.copy(n):this[t]=n}}toJSON(e){const t=e===void 0||typeof e=="string";t&&(e={textures:{},images:{}});const n={metadata:{version:4.6,type:"Material",generator:"Material.toJSON"}};n.uuid=this.uuid,n.type=this.type,this.name!==""&&(n.name=this.name),this.color&&this.color.isColor&&(n.color=this.color.getHex()),this.roughness!==void 0&&(n.roughness=this.roughness),this.metalness!==void 0&&(n.metalness=this.metalness),this.sheen!==void 0&&(n.sheen=this.sheen),this.sheenColor&&this.sheenColor.isColor&&(n.sheenColor=this.sheenColor.getHex()),this.sheenRoughness!==void 0&&(n.sheenRoughness=this.sheenRoughness),this.emissive&&this.emissive.isColor&&(n.emissive=this.emissive.getHex()),this.emissiveIntensity!==void 0&&this.emissiveIntensity!==1&&(n.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(n.specular=this.specular.getHex()),this.specularIntensity!==void 0&&(n.specularIntensity=this.specularIntensity),this.specularColor&&this.specularColor.isColor&&(n.specularColor=this.specularColor.getHex()),this.shininess!==void 0&&(n.shininess=this.shininess),this.clearcoat!==void 0&&(n.clearcoat=this.clearcoat),this.clearcoatRoughness!==void 0&&(n.clearcoatRoughness=this.clearcoatRoughness),this.clearcoatMap&&this.clearcoatMap.isTexture&&(n.clearcoatMap=this.clearcoatMap.toJSON(e).uuid),this.clearcoatRoughnessMap&&this.clearcoatRoughnessMap.isTexture&&(n.clearcoatRoughnessMap=this.clearcoatRoughnessMap.toJSON(e).uuid),this.clearcoatNormalMap&&this.clearcoatNormalMap.isTexture&&(n.clearcoatNormalMap=this.clearcoatNormalMap.toJSON(e).uuid,n.clearcoatNormalScale=this.clearcoatNormalScale.toArray()),this.dispersion!==void 0&&(n.dispersion=this.dispersion),this.iridescence!==void 0&&(n.iridescence=this.iridescence),this.iridescenceIOR!==void 0&&(n.iridescenceIOR=this.iridescenceIOR),this.iridescenceThicknessRange!==void 0&&(n.iridescenceThicknessRange=this.iridescenceThicknessRange),this.iridescenceMap&&this.iridescenceMap.isTexture&&(n.iridescenceMap=this.iridescenceMap.toJSON(e).uuid),this.iridescenceThicknessMap&&this.iridescenceThicknessMap.isTexture&&(n.iridescenceThicknessMap=this.iridescenceThicknessMap.toJSON(e).uuid),this.anisotropy!==void 0&&(n.anisotropy=this.anisotropy),this.anisotropyRotation!==void 0&&(n.anisotropyRotation=this.anisotropyRotation),this.anisotropyMap&&this.anisotropyMap.isTexture&&(n.anisotropyMap=this.anisotropyMap.toJSON(e).uuid),this.map&&this.map.isTexture&&(n.map=this.map.toJSON(e).uuid),this.matcap&&this.matcap.isTexture&&(n.matcap=this.matcap.toJSON(e).uuid),this.alphaMap&&this.alphaMap.isTexture&&(n.alphaMap=this.alphaMap.toJSON(e).uuid),this.lightMap&&this.lightMap.isTexture&&(n.lightMap=this.lightMap.toJSON(e).uuid,n.lightMapIntensity=this.lightMapIntensity),this.aoMap&&this.aoMap.isTexture&&(n.aoMap=this.aoMap.toJSON(e).uuid,n.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(n.bumpMap=this.bumpMap.toJSON(e).uuid,n.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(n.normalMap=this.normalMap.toJSON(e).uuid,n.normalMapType=this.normalMapType,n.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(n.displacementMap=this.displacementMap.toJSON(e).uuid,n.displacementScale=this.displacementScale,n.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(n.roughnessMap=this.roughnessMap.toJSON(e).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(n.metalnessMap=this.metalnessMap.toJSON(e).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(n.emissiveMap=this.emissiveMap.toJSON(e).uuid),this.specularMap&&this.specularMap.isTexture&&(n.specularMap=this.specularMap.toJSON(e).uuid),this.specularIntensityMap&&this.specularIntensityMap.isTexture&&(n.specularIntensityMap=this.specularIntensityMap.toJSON(e).uuid),this.specularColorMap&&this.specularColorMap.isTexture&&(n.specularColorMap=this.specularColorMap.toJSON(e).uuid),this.envMap&&this.envMap.isTexture&&(n.envMap=this.envMap.toJSON(e).uuid,this.combine!==void 0&&(n.combine=this.combine)),this.envMapRotation!==void 0&&(n.envMapRotation=this.envMapRotation.toArray()),this.envMapIntensity!==void 0&&(n.envMapIntensity=this.envMapIntensity),this.reflectivity!==void 0&&(n.reflectivity=this.reflectivity),this.refractionRatio!==void 0&&(n.refractionRatio=this.refractionRatio),this.gradientMap&&this.gradientMap.isTexture&&(n.gradientMap=this.gradientMap.toJSON(e).uuid),this.transmission!==void 0&&(n.transmission=this.transmission),this.transmissionMap&&this.transmissionMap.isTexture&&(n.transmissionMap=this.transmissionMap.toJSON(e).uuid),this.thickness!==void 0&&(n.thickness=this.thickness),this.thicknessMap&&this.thicknessMap.isTexture&&(n.thicknessMap=this.thicknessMap.toJSON(e).uuid),this.attenuationDistance!==void 0&&this.attenuationDistance!==1/0&&(n.attenuationDistance=this.attenuationDistance),this.attenuationColor!==void 0&&(n.attenuationColor=this.attenuationColor.getHex()),this.size!==void 0&&(n.size=this.size),this.shadowSide!==null&&(n.shadowSide=this.shadowSide),this.sizeAttenuation!==void 0&&(n.sizeAttenuation=this.sizeAttenuation),this.blending!==vs&&(n.blending=this.blending),this.side!==or&&(n.side=this.side),this.vertexColors===!0&&(n.vertexColors=!0),this.opacity<1&&(n.opacity=this.opacity),this.transparent===!0&&(n.transparent=!0),this.blendSrc!==nc&&(n.blendSrc=this.blendSrc),this.blendDst!==ic&&(n.blendDst=this.blendDst),this.blendEquation!==Rr&&(n.blendEquation=this.blendEquation),this.blendSrcAlpha!==null&&(n.blendSrcAlpha=this.blendSrcAlpha),this.blendDstAlpha!==null&&(n.blendDstAlpha=this.blendDstAlpha),this.blendEquationAlpha!==null&&(n.blendEquationAlpha=this.blendEquationAlpha),this.blendColor&&this.blendColor.isColor&&(n.blendColor=this.blendColor.getHex()),this.blendAlpha!==0&&(n.blendAlpha=this.blendAlpha),this.depthFunc!==ws&&(n.depthFunc=this.depthFunc),this.depthTest===!1&&(n.depthTest=this.depthTest),this.depthWrite===!1&&(n.depthWrite=this.depthWrite),this.colorWrite===!1&&(n.colorWrite=this.colorWrite),this.stencilWriteMask!==255&&(n.stencilWriteMask=this.stencilWriteMask),this.stencilFunc!==Ju&&(n.stencilFunc=this.stencilFunc),this.stencilRef!==0&&(n.stencilRef=this.stencilRef),this.stencilFuncMask!==255&&(n.stencilFuncMask=this.stencilFuncMask),this.stencilFail!==$r&&(n.stencilFail=this.stencilFail),this.stencilZFail!==$r&&(n.stencilZFail=this.stencilZFail),this.stencilZPass!==$r&&(n.stencilZPass=this.stencilZPass),this.stencilWrite===!0&&(n.stencilWrite=this.stencilWrite),this.rotation!==void 0&&this.rotation!==0&&(n.rotation=this.rotation),this.polygonOffset===!0&&(n.polygonOffset=!0),this.polygonOffsetFactor!==0&&(n.polygonOffsetFactor=this.polygonOffsetFactor),this.polygonOffsetUnits!==0&&(n.polygonOffsetUnits=this.polygonOffsetUnits),this.linewidth!==void 0&&this.linewidth!==1&&(n.linewidth=this.linewidth),this.dashSize!==void 0&&(n.dashSize=this.dashSize),this.gapSize!==void 0&&(n.gapSize=this.gapSize),this.scale!==void 0&&(n.scale=this.scale),this.dithering===!0&&(n.dithering=!0),this.alphaTest>0&&(n.alphaTest=this.alphaTest),this.alphaHash===!0&&(n.alphaHash=!0),this.alphaToCoverage===!0&&(n.alphaToCoverage=!0),this.premultipliedAlpha===!0&&(n.premultipliedAlpha=!0),this.forceSinglePass===!0&&(n.forceSinglePass=!0),this.wireframe===!0&&(n.wireframe=!0),this.wireframeLinewidth>1&&(n.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!=="round"&&(n.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!=="round"&&(n.wireframeLinejoin=this.wireframeLinejoin),this.flatShading===!0&&(n.flatShading=!0),this.visible===!1&&(n.visible=!1),this.toneMapped===!1&&(n.toneMapped=!1),this.fog===!1&&(n.fog=!1),Object.keys(this.userData).length>0&&(n.userData=this.userData);function i(s){const a=[];for(const o in s){const l=s[o];delete l.metadata,a.push(l)}return a}if(t){const s=i(e.textures),a=i(e.images);s.length>0&&(n.textures=s),a.length>0&&(n.images=a)}return n}clone(){return new this.constructor().copy(this)}copy(e){this.name=e.name,this.blending=e.blending,this.side=e.side,this.vertexColors=e.vertexColors,this.opacity=e.opacity,this.transparent=e.transparent,this.blendSrc=e.blendSrc,this.blendDst=e.blendDst,this.blendEquation=e.blendEquation,this.blendSrcAlpha=e.blendSrcAlpha,this.blendDstAlpha=e.blendDstAlpha,this.blendEquationAlpha=e.blendEquationAlpha,this.blendColor.copy(e.blendColor),this.blendAlpha=e.blendAlpha,this.depthFunc=e.depthFunc,this.depthTest=e.depthTest,this.depthWrite=e.depthWrite,this.stencilWriteMask=e.stencilWriteMask,this.stencilFunc=e.stencilFunc,this.stencilRef=e.stencilRef,this.stencilFuncMask=e.stencilFuncMask,this.stencilFail=e.stencilFail,this.stencilZFail=e.stencilZFail,this.stencilZPass=e.stencilZPass,this.stencilWrite=e.stencilWrite;const t=e.clippingPlanes;let n=null;if(t!==null){const i=t.length;n=new Array(i);for(let s=0;s!==i;++s)n[s]=t[s].clone()}return this.clippingPlanes=n,this.clipIntersection=e.clipIntersection,this.clipShadows=e.clipShadows,this.shadowSide=e.shadowSide,this.colorWrite=e.colorWrite,this.precision=e.precision,this.polygonOffset=e.polygonOffset,this.polygonOffsetFactor=e.polygonOffsetFactor,this.polygonOffsetUnits=e.polygonOffsetUnits,this.dithering=e.dithering,this.alphaTest=e.alphaTest,this.alphaHash=e.alphaHash,this.alphaToCoverage=e.alphaToCoverage,this.premultipliedAlpha=e.premultipliedAlpha,this.forceSinglePass=e.forceSinglePass,this.visible=e.visible,this.toneMapped=e.toneMapped,this.userData=JSON.parse(JSON.stringify(e.userData)),this}dispose(){this.dispatchEvent({type:"dispose"})}set needsUpdate(e){e===!0&&this.version++}onBuild(){console.warn("Material: onBuild() has been removed.")}}class Jh extends Vs{constructor(e){super(),this.isMeshBasicMaterial=!0,this.type="MeshBasicMaterial",this.color=new nt(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new ki,this.combine=Uh,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.color.copy(e.color),this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.specularMap=e.specularMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.envMapRotation.copy(e.envMapRotation),this.combine=e.combine,this.reflectivity=e.reflectivity,this.refractionRatio=e.refractionRatio,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.fog=e.fog,this}}const Bt=new X,Ya=new Mt;class En{constructor(e,t,n=!1){if(Array.isArray(e))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.isBufferAttribute=!0,this.name="",this.array=e,this.itemSize=t,this.count=e!==void 0?e.length/t:0,this.normalized=n,this.usage=Qu,this.updateRanges=[],this.gpuType=Li,this.version=0}onUploadCallback(){}set needsUpdate(e){e===!0&&this.version++}setUsage(e){return this.usage=e,this}addUpdateRange(e,t){this.updateRanges.push({start:e,count:t})}clearUpdateRanges(){this.updateRanges.length=0}copy(e){return this.name=e.name,this.array=new e.array.constructor(e.array),this.itemSize=e.itemSize,this.count=e.count,this.normalized=e.normalized,this.usage=e.usage,this.gpuType=e.gpuType,this}copyAt(e,t,n){e*=this.itemSize,n*=t.itemSize;for(let i=0,s=this.itemSize;i<s;i++)this.array[e+i]=t.array[n+i];return this}copyArray(e){return this.array.set(e),this}applyMatrix3(e){if(this.itemSize===2)for(let t=0,n=this.count;t<n;t++)Ya.fromBufferAttribute(this,t),Ya.applyMatrix3(e),this.setXY(t,Ya.x,Ya.y);else if(this.itemSize===3)for(let t=0,n=this.count;t<n;t++)Bt.fromBufferAttribute(this,t),Bt.applyMatrix3(e),this.setXYZ(t,Bt.x,Bt.y,Bt.z);return this}applyMatrix4(e){for(let t=0,n=this.count;t<n;t++)Bt.fromBufferAttribute(this,t),Bt.applyMatrix4(e),this.setXYZ(t,Bt.x,Bt.y,Bt.z);return this}applyNormalMatrix(e){for(let t=0,n=this.count;t<n;t++)Bt.fromBufferAttribute(this,t),Bt.applyNormalMatrix(e),this.setXYZ(t,Bt.x,Bt.y,Bt.z);return this}transformDirection(e){for(let t=0,n=this.count;t<n;t++)Bt.fromBufferAttribute(this,t),Bt.transformDirection(e),this.setXYZ(t,Bt.x,Bt.y,Bt.z);return this}set(e,t=0){return this.array.set(e,t),this}getComponent(e,t){let n=this.array[e*this.itemSize+t];return this.normalized&&(n=Xs(n,this.array)),n}setComponent(e,t,n){return this.normalized&&(n=Sn(n,this.array)),this.array[e*this.itemSize+t]=n,this}getX(e){let t=this.array[e*this.itemSize];return this.normalized&&(t=Xs(t,this.array)),t}setX(e,t){return this.normalized&&(t=Sn(t,this.array)),this.array[e*this.itemSize]=t,this}getY(e){let t=this.array[e*this.itemSize+1];return this.normalized&&(t=Xs(t,this.array)),t}setY(e,t){return this.normalized&&(t=Sn(t,this.array)),this.array[e*this.itemSize+1]=t,this}getZ(e){let t=this.array[e*this.itemSize+2];return this.normalized&&(t=Xs(t,this.array)),t}setZ(e,t){return this.normalized&&(t=Sn(t,this.array)),this.array[e*this.itemSize+2]=t,this}getW(e){let t=this.array[e*this.itemSize+3];return this.normalized&&(t=Xs(t,this.array)),t}setW(e,t){return this.normalized&&(t=Sn(t,this.array)),this.array[e*this.itemSize+3]=t,this}setXY(e,t,n){return e*=this.itemSize,this.normalized&&(t=Sn(t,this.array),n=Sn(n,this.array)),this.array[e+0]=t,this.array[e+1]=n,this}setXYZ(e,t,n,i){return e*=this.itemSize,this.normalized&&(t=Sn(t,this.array),n=Sn(n,this.array),i=Sn(i,this.array)),this.array[e+0]=t,this.array[e+1]=n,this.array[e+2]=i,this}setXYZW(e,t,n,i,s){return e*=this.itemSize,this.normalized&&(t=Sn(t,this.array),n=Sn(n,this.array),i=Sn(i,this.array),s=Sn(s,this.array)),this.array[e+0]=t,this.array[e+1]=n,this.array[e+2]=i,this.array[e+3]=s,this}onUpload(e){return this.onUploadCallback=e,this}clone(){return new this.constructor(this.array,this.itemSize).copy(this)}toJSON(){const e={itemSize:this.itemSize,type:this.array.constructor.name,array:Array.from(this.array),normalized:this.normalized};return this.name!==""&&(e.name=this.name),this.usage!==Qu&&(e.usage=this.usage),e}}class Qh extends En{constructor(e,t,n){super(new Uint16Array(e),t,n)}}class ed extends En{constructor(e,t,n){super(new Uint32Array(e),t,n)}}class Oi extends En{constructor(e,t,n){super(new Float32Array(e),t,n)}}let Gm=0;const Kn=new Lt,Pl=new xn,rs=new X,Un=new Ua,Ks=new Ua,$t=new X;class hi extends Hs{constructor(){super(),this.isBufferGeometry=!0,Object.defineProperty(this,"id",{value:Gm++}),this.uuid=La(),this.name="",this.type="BufferGeometry",this.index=null,this.indirect=null,this.attributes={},this.morphAttributes={},this.morphTargetsRelative=!1,this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={}}getIndex(){return this.index}setIndex(e){return Array.isArray(e)?this.index=new(Yh(e)?ed:Qh)(e,1):this.index=e,this}setIndirect(e){return this.indirect=e,this}getIndirect(){return this.indirect}getAttribute(e){return this.attributes[e]}setAttribute(e,t){return this.attributes[e]=t,this}deleteAttribute(e){return delete this.attributes[e],this}hasAttribute(e){return this.attributes[e]!==void 0}addGroup(e,t,n=0){this.groups.push({start:e,count:t,materialIndex:n})}clearGroups(){this.groups=[]}setDrawRange(e,t){this.drawRange.start=e,this.drawRange.count=t}applyMatrix4(e){const t=this.attributes.position;t!==void 0&&(t.applyMatrix4(e),t.needsUpdate=!0);const n=this.attributes.normal;if(n!==void 0){const s=new qe().getNormalMatrix(e);n.applyNormalMatrix(s),n.needsUpdate=!0}const i=this.attributes.tangent;return i!==void 0&&(i.transformDirection(e),i.needsUpdate=!0),this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this}applyQuaternion(e){return Kn.makeRotationFromQuaternion(e),this.applyMatrix4(Kn),this}rotateX(e){return Kn.makeRotationX(e),this.applyMatrix4(Kn),this}rotateY(e){return Kn.makeRotationY(e),this.applyMatrix4(Kn),this}rotateZ(e){return Kn.makeRotationZ(e),this.applyMatrix4(Kn),this}translate(e,t,n){return Kn.makeTranslation(e,t,n),this.applyMatrix4(Kn),this}scale(e,t,n){return Kn.makeScale(e,t,n),this.applyMatrix4(Kn),this}lookAt(e){return Pl.lookAt(e),Pl.updateMatrix(),this.applyMatrix4(Pl.matrix),this}center(){return this.computeBoundingBox(),this.boundingBox.getCenter(rs).negate(),this.translate(rs.x,rs.y,rs.z),this}setFromPoints(e){const t=this.getAttribute("position");if(t===void 0){const n=[];for(let i=0,s=e.length;i<s;i++){const a=e[i];n.push(a.x,a.y,a.z||0)}this.setAttribute("position",new Oi(n,3))}else{const n=Math.min(e.length,t.count);for(let i=0;i<n;i++){const s=e[i];t.setXYZ(i,s.x,s.y,s.z||0)}e.length>t.count&&console.warn("THREE.BufferGeometry: Buffer size too small for points data. Use .dispose() and create a new geometry."),t.needsUpdate=!0}return this}computeBoundingBox(){this.boundingBox===null&&(this.boundingBox=new Ua);const e=this.attributes.position,t=this.morphAttributes.position;if(e&&e.isGLBufferAttribute){console.error("THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box.",this),this.boundingBox.set(new X(-1/0,-1/0,-1/0),new X(1/0,1/0,1/0));return}if(e!==void 0){if(this.boundingBox.setFromBufferAttribute(e),t)for(let n=0,i=t.length;n<i;n++){const s=t[n];Un.setFromBufferAttribute(s),this.morphTargetsRelative?($t.addVectors(this.boundingBox.min,Un.min),this.boundingBox.expandByPoint($t),$t.addVectors(this.boundingBox.max,Un.max),this.boundingBox.expandByPoint($t)):(this.boundingBox.expandByPoint(Un.min),this.boundingBox.expandByPoint(Un.max))}}else this.boundingBox.makeEmpty();(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&console.error('THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)}computeBoundingSphere(){this.boundingSphere===null&&(this.boundingSphere=new Na);const e=this.attributes.position,t=this.morphAttributes.position;if(e&&e.isGLBufferAttribute){console.error("THREE.BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere.",this),this.boundingSphere.set(new X,1/0);return}if(e){const n=this.boundingSphere.center;if(Un.setFromBufferAttribute(e),t)for(let s=0,a=t.length;s<a;s++){const o=t[s];Ks.setFromBufferAttribute(o),this.morphTargetsRelative?($t.addVectors(Un.min,Ks.min),Un.expandByPoint($t),$t.addVectors(Un.max,Ks.max),Un.expandByPoint($t)):(Un.expandByPoint(Ks.min),Un.expandByPoint(Ks.max))}Un.getCenter(n);let i=0;for(let s=0,a=e.count;s<a;s++)$t.fromBufferAttribute(e,s),i=Math.max(i,n.distanceToSquared($t));if(t)for(let s=0,a=t.length;s<a;s++){const o=t[s],l=this.morphTargetsRelative;for(let c=0,u=o.count;c<u;c++)$t.fromBufferAttribute(o,c),l&&(rs.fromBufferAttribute(e,c),$t.add(rs)),i=Math.max(i,n.distanceToSquared($t))}this.boundingSphere.radius=Math.sqrt(i),isNaN(this.boundingSphere.radius)&&console.error('THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}computeTangents(){const e=this.index,t=this.attributes;if(e===null||t.position===void 0||t.normal===void 0||t.uv===void 0){console.error("THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)");return}const n=t.position,i=t.normal,s=t.uv;this.hasAttribute("tangent")===!1&&this.setAttribute("tangent",new En(new Float32Array(4*n.count),4));const a=this.getAttribute("tangent"),o=[],l=[];for(let C=0;C<n.count;C++)o[C]=new X,l[C]=new X;const c=new X,u=new X,h=new X,d=new Mt,f=new Mt,g=new Mt,_=new X,m=new X;function p(C,M,v){c.fromBufferAttribute(n,C),u.fromBufferAttribute(n,M),h.fromBufferAttribute(n,v),d.fromBufferAttribute(s,C),f.fromBufferAttribute(s,M),g.fromBufferAttribute(s,v),u.sub(c),h.sub(c),f.sub(d),g.sub(d);const P=1/(f.x*g.y-g.x*f.y);isFinite(P)&&(_.copy(u).multiplyScalar(g.y).addScaledVector(h,-f.y).multiplyScalar(P),m.copy(h).multiplyScalar(f.x).addScaledVector(u,-g.x).multiplyScalar(P),o[C].add(_),o[M].add(_),o[v].add(_),l[C].add(m),l[M].add(m),l[v].add(m))}let T=this.groups;T.length===0&&(T=[{start:0,count:e.count}]);for(let C=0,M=T.length;C<M;++C){const v=T[C],P=v.start,U=v.count;for(let O=P,G=P+U;O<G;O+=3)p(e.getX(O+0),e.getX(O+1),e.getX(O+2))}const E=new X,x=new X,R=new X,w=new X;function b(C){R.fromBufferAttribute(i,C),w.copy(R);const M=o[C];E.copy(M),E.sub(R.multiplyScalar(R.dot(M))).normalize(),x.crossVectors(w,M);const P=x.dot(l[C])<0?-1:1;a.setXYZW(C,E.x,E.y,E.z,P)}for(let C=0,M=T.length;C<M;++C){const v=T[C],P=v.start,U=v.count;for(let O=P,G=P+U;O<G;O+=3)b(e.getX(O+0)),b(e.getX(O+1)),b(e.getX(O+2))}}computeVertexNormals(){const e=this.index,t=this.getAttribute("position");if(t!==void 0){let n=this.getAttribute("normal");if(n===void 0)n=new En(new Float32Array(t.count*3),3),this.setAttribute("normal",n);else for(let d=0,f=n.count;d<f;d++)n.setXYZ(d,0,0,0);const i=new X,s=new X,a=new X,o=new X,l=new X,c=new X,u=new X,h=new X;if(e)for(let d=0,f=e.count;d<f;d+=3){const g=e.getX(d+0),_=e.getX(d+1),m=e.getX(d+2);i.fromBufferAttribute(t,g),s.fromBufferAttribute(t,_),a.fromBufferAttribute(t,m),u.subVectors(a,s),h.subVectors(i,s),u.cross(h),o.fromBufferAttribute(n,g),l.fromBufferAttribute(n,_),c.fromBufferAttribute(n,m),o.add(u),l.add(u),c.add(u),n.setXYZ(g,o.x,o.y,o.z),n.setXYZ(_,l.x,l.y,l.z),n.setXYZ(m,c.x,c.y,c.z)}else for(let d=0,f=t.count;d<f;d+=3)i.fromBufferAttribute(t,d+0),s.fromBufferAttribute(t,d+1),a.fromBufferAttribute(t,d+2),u.subVectors(a,s),h.subVectors(i,s),u.cross(h),n.setXYZ(d+0,u.x,u.y,u.z),n.setXYZ(d+1,u.x,u.y,u.z),n.setXYZ(d+2,u.x,u.y,u.z);this.normalizeNormals(),n.needsUpdate=!0}}normalizeNormals(){const e=this.attributes.normal;for(let t=0,n=e.count;t<n;t++)$t.fromBufferAttribute(e,t),$t.normalize(),e.setXYZ(t,$t.x,$t.y,$t.z)}toNonIndexed(){function e(o,l){const c=o.array,u=o.itemSize,h=o.normalized,d=new c.constructor(l.length*u);let f=0,g=0;for(let _=0,m=l.length;_<m;_++){o.isInterleavedBufferAttribute?f=l[_]*o.data.stride+o.offset:f=l[_]*u;for(let p=0;p<u;p++)d[g++]=c[f++]}return new En(d,u,h)}if(this.index===null)return console.warn("THREE.BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed."),this;const t=new hi,n=this.index.array,i=this.attributes;for(const o in i){const l=i[o],c=e(l,n);t.setAttribute(o,c)}const s=this.morphAttributes;for(const o in s){const l=[],c=s[o];for(let u=0,h=c.length;u<h;u++){const d=c[u],f=e(d,n);l.push(f)}t.morphAttributes[o]=l}t.morphTargetsRelative=this.morphTargetsRelative;const a=this.groups;for(let o=0,l=a.length;o<l;o++){const c=a[o];t.addGroup(c.start,c.count,c.materialIndex)}return t}toJSON(){const e={metadata:{version:4.6,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(e.uuid=this.uuid,e.type=this.type,this.name!==""&&(e.name=this.name),Object.keys(this.userData).length>0&&(e.userData=this.userData),this.parameters!==void 0){const l=this.parameters;for(const c in l)l[c]!==void 0&&(e[c]=l[c]);return e}e.data={attributes:{}};const t=this.index;t!==null&&(e.data.index={type:t.array.constructor.name,array:Array.prototype.slice.call(t.array)});const n=this.attributes;for(const l in n){const c=n[l];e.data.attributes[l]=c.toJSON(e.data)}const i={};let s=!1;for(const l in this.morphAttributes){const c=this.morphAttributes[l],u=[];for(let h=0,d=c.length;h<d;h++){const f=c[h];u.push(f.toJSON(e.data))}u.length>0&&(i[l]=u,s=!0)}s&&(e.data.morphAttributes=i,e.data.morphTargetsRelative=this.morphTargetsRelative);const a=this.groups;a.length>0&&(e.data.groups=JSON.parse(JSON.stringify(a)));const o=this.boundingSphere;return o!==null&&(e.data.boundingSphere={center:o.center.toArray(),radius:o.radius}),e}clone(){return new this.constructor().copy(this)}copy(e){this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null;const t={};this.name=e.name;const n=e.index;n!==null&&this.setIndex(n.clone(t));const i=e.attributes;for(const c in i){const u=i[c];this.setAttribute(c,u.clone(t))}const s=e.morphAttributes;for(const c in s){const u=[],h=s[c];for(let d=0,f=h.length;d<f;d++)u.push(h[d].clone(t));this.morphAttributes[c]=u}this.morphTargetsRelative=e.morphTargetsRelative;const a=e.groups;for(let c=0,u=a.length;c<u;c++){const h=a[c];this.addGroup(h.start,h.count,h.materialIndex)}const o=e.boundingBox;o!==null&&(this.boundingBox=o.clone());const l=e.boundingSphere;return l!==null&&(this.boundingSphere=l.clone()),this.drawRange.start=e.drawRange.start,this.drawRange.count=e.drawRange.count,this.userData=e.userData,this}dispose(){this.dispatchEvent({type:"dispose"})}}const pf=new Lt,gr=new Su,$a=new Na,mf=new X,Ka=new X,Za=new X,ja=new X,Dl=new X,Ja=new X,_f=new X,Qa=new X;class Ui extends xn{constructor(e=new hi,t=new Jh){super(),this.isMesh=!0,this.type="Mesh",this.geometry=e,this.material=t,this.updateMorphTargets()}copy(e,t){return super.copy(e,t),e.morphTargetInfluences!==void 0&&(this.morphTargetInfluences=e.morphTargetInfluences.slice()),e.morphTargetDictionary!==void 0&&(this.morphTargetDictionary=Object.assign({},e.morphTargetDictionary)),this.material=Array.isArray(e.material)?e.material.slice():e.material,this.geometry=e.geometry,this}updateMorphTargets(){const t=this.geometry.morphAttributes,n=Object.keys(t);if(n.length>0){const i=t[n[0]];if(i!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,a=i.length;s<a;s++){const o=i[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[o]=s}}}}getVertexPosition(e,t){const n=this.geometry,i=n.attributes.position,s=n.morphAttributes.position,a=n.morphTargetsRelative;t.fromBufferAttribute(i,e);const o=this.morphTargetInfluences;if(s&&o){Ja.set(0,0,0);for(let l=0,c=s.length;l<c;l++){const u=o[l],h=s[l];u!==0&&(Dl.fromBufferAttribute(h,e),a?Ja.addScaledVector(Dl,u):Ja.addScaledVector(Dl.sub(t),u))}t.add(Ja)}return t}raycast(e,t){const n=this.geometry,i=this.material,s=this.matrixWorld;i!==void 0&&(n.boundingSphere===null&&n.computeBoundingSphere(),$a.copy(n.boundingSphere),$a.applyMatrix4(s),gr.copy(e.ray).recast(e.near),!($a.containsPoint(gr.origin)===!1&&(gr.intersectSphere($a,mf)===null||gr.origin.distanceToSquared(mf)>(e.far-e.near)**2))&&(pf.copy(s).invert(),gr.copy(e.ray).applyMatrix4(pf),!(n.boundingBox!==null&&gr.intersectsBox(n.boundingBox)===!1)&&this._computeIntersections(e,t,gr)))}_computeIntersections(e,t,n){let i;const s=this.geometry,a=this.material,o=s.index,l=s.attributes.position,c=s.attributes.uv,u=s.attributes.uv1,h=s.attributes.normal,d=s.groups,f=s.drawRange;if(o!==null)if(Array.isArray(a))for(let g=0,_=d.length;g<_;g++){const m=d[g],p=a[m.materialIndex],T=Math.max(m.start,f.start),E=Math.min(o.count,Math.min(m.start+m.count,f.start+f.count));for(let x=T,R=E;x<R;x+=3){const w=o.getX(x),b=o.getX(x+1),C=o.getX(x+2);i=eo(this,p,e,n,c,u,h,w,b,C),i&&(i.faceIndex=Math.floor(x/3),i.face.materialIndex=m.materialIndex,t.push(i))}}else{const g=Math.max(0,f.start),_=Math.min(o.count,f.start+f.count);for(let m=g,p=_;m<p;m+=3){const T=o.getX(m),E=o.getX(m+1),x=o.getX(m+2);i=eo(this,a,e,n,c,u,h,T,E,x),i&&(i.faceIndex=Math.floor(m/3),t.push(i))}}else if(l!==void 0)if(Array.isArray(a))for(let g=0,_=d.length;g<_;g++){const m=d[g],p=a[m.materialIndex],T=Math.max(m.start,f.start),E=Math.min(l.count,Math.min(m.start+m.count,f.start+f.count));for(let x=T,R=E;x<R;x+=3){const w=x,b=x+1,C=x+2;i=eo(this,p,e,n,c,u,h,w,b,C),i&&(i.faceIndex=Math.floor(x/3),i.face.materialIndex=m.materialIndex,t.push(i))}}else{const g=Math.max(0,f.start),_=Math.min(l.count,f.start+f.count);for(let m=g,p=_;m<p;m+=3){const T=m,E=m+1,x=m+2;i=eo(this,a,e,n,c,u,h,T,E,x),i&&(i.faceIndex=Math.floor(m/3),t.push(i))}}}}function Wm(r,e,t,n,i,s,a,o){let l;if(e.side===Tn?l=n.intersectTriangle(a,s,i,!0,o):l=n.intersectTriangle(i,s,a,e.side===or,o),l===null)return null;Qa.copy(o),Qa.applyMatrix4(r.matrixWorld);const c=t.ray.origin.distanceTo(Qa);return c<t.near||c>t.far?null:{distance:c,point:Qa.clone(),object:r}}function eo(r,e,t,n,i,s,a,o,l,c){r.getVertexPosition(o,Ka),r.getVertexPosition(l,Za),r.getVertexPosition(c,ja);const u=Wm(r,e,t,n,Ka,Za,ja,_f);if(u){const h=new X;ci.getBarycoord(_f,Ka,Za,ja,h),i&&(u.uv=ci.getInterpolatedAttribute(i,o,l,c,h,new Mt)),s&&(u.uv1=ci.getInterpolatedAttribute(s,o,l,c,h,new Mt)),a&&(u.normal=ci.getInterpolatedAttribute(a,o,l,c,h,new X),u.normal.dot(n.direction)>0&&u.normal.multiplyScalar(-1));const d={a:o,b:l,c,normal:new X,materialIndex:0};ci.getNormal(Ka,Za,ja,d.normal),u.face=d,u.barycoord=h}return u}class Fa extends hi{constructor(e=1,t=1,n=1,i=1,s=1,a=1){super(),this.type="BoxGeometry",this.parameters={width:e,height:t,depth:n,widthSegments:i,heightSegments:s,depthSegments:a};const o=this;i=Math.floor(i),s=Math.floor(s),a=Math.floor(a);const l=[],c=[],u=[],h=[];let d=0,f=0;g("z","y","x",-1,-1,n,t,e,a,s,0),g("z","y","x",1,-1,n,t,-e,a,s,1),g("x","z","y",1,1,e,n,t,i,a,2),g("x","z","y",1,-1,e,n,-t,i,a,3),g("x","y","z",1,-1,e,t,n,i,s,4),g("x","y","z",-1,-1,e,t,-n,i,s,5),this.setIndex(l),this.setAttribute("position",new Oi(c,3)),this.setAttribute("normal",new Oi(u,3)),this.setAttribute("uv",new Oi(h,2));function g(_,m,p,T,E,x,R,w,b,C,M){const v=x/b,P=R/C,U=x/2,O=R/2,G=w/2,Y=b+1,H=C+1;let q=0,k=0;const ne=new X;for(let D=0;D<H;D++){const ue=D*P-O;for(let Ie=0;Ie<Y;Ie++){const $e=Ie*v-U;ne[_]=$e*T,ne[m]=ue*E,ne[p]=G,c.push(ne.x,ne.y,ne.z),ne[_]=0,ne[m]=0,ne[p]=w>0?1:-1,u.push(ne.x,ne.y,ne.z),h.push(Ie/b),h.push(1-D/C),q+=1}}for(let D=0;D<C;D++)for(let ue=0;ue<b;ue++){const Ie=d+ue+Y*D,$e=d+ue+Y*(D+1),K=d+(ue+1)+Y*(D+1),te=d+(ue+1)+Y*D;l.push(Ie,$e,te),l.push($e,K,te),k+=6}o.addGroup(f,k,M),f+=k,d+=q}}copy(e){return super.copy(e),this.parameters=Object.assign({},e.parameters),this}static fromJSON(e){return new Fa(e.width,e.height,e.depth,e.widthSegments,e.heightSegments,e.depthSegments)}}function Is(r){const e={};for(const t in r){e[t]={};for(const n in r[t]){const i=r[t][n];i&&(i.isColor||i.isMatrix3||i.isMatrix4||i.isVector2||i.isVector3||i.isVector4||i.isTexture||i.isQuaternion)?i.isRenderTargetTexture?(console.warn("UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms()."),e[t][n]=null):e[t][n]=i.clone():Array.isArray(i)?e[t][n]=i.slice():e[t][n]=i}}return e}function dn(r){const e={};for(let t=0;t<r.length;t++){const n=Is(r[t]);for(const i in n)e[i]=n[i]}return e}function Xm(r){const e=[];for(let t=0;t<r.length;t++)e.push(r[t].clone());return e}function td(r){const e=r.getRenderTarget();return e===null?r.outputColorSpace:e.isXRRenderTarget===!0?e.texture.colorSpace:ut.workingColorSpace}const qm={clone:Is,merge:dn};var Ym=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,$m=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`;class lr extends Vs{constructor(e){super(),this.isShaderMaterial=!0,this.type="ShaderMaterial",this.defines={},this.uniforms={},this.uniformsGroups=[],this.vertexShader=Ym,this.fragmentShader=$m,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.forceSinglePass=!0,this.extensions={clipCullDistance:!1,multiDraw:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv1:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,this.glslVersion=null,e!==void 0&&this.setValues(e)}copy(e){return super.copy(e),this.fragmentShader=e.fragmentShader,this.vertexShader=e.vertexShader,this.uniforms=Is(e.uniforms),this.uniformsGroups=Xm(e.uniformsGroups),this.defines=Object.assign({},e.defines),this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.fog=e.fog,this.lights=e.lights,this.clipping=e.clipping,this.extensions=Object.assign({},e.extensions),this.glslVersion=e.glslVersion,this}toJSON(e){const t=super.toJSON(e);t.glslVersion=this.glslVersion,t.uniforms={};for(const i in this.uniforms){const a=this.uniforms[i].value;a&&a.isTexture?t.uniforms[i]={type:"t",value:a.toJSON(e).uuid}:a&&a.isColor?t.uniforms[i]={type:"c",value:a.getHex()}:a&&a.isVector2?t.uniforms[i]={type:"v2",value:a.toArray()}:a&&a.isVector3?t.uniforms[i]={type:"v3",value:a.toArray()}:a&&a.isVector4?t.uniforms[i]={type:"v4",value:a.toArray()}:a&&a.isMatrix3?t.uniforms[i]={type:"m3",value:a.toArray()}:a&&a.isMatrix4?t.uniforms[i]={type:"m4",value:a.toArray()}:t.uniforms[i]={value:a}}Object.keys(this.defines).length>0&&(t.defines=this.defines),t.vertexShader=this.vertexShader,t.fragmentShader=this.fragmentShader,t.lights=this.lights,t.clipping=this.clipping;const n={};for(const i in this.extensions)this.extensions[i]===!0&&(n[i]=!0);return Object.keys(n).length>0&&(t.extensions=n),t}}class nd extends xn{constructor(){super(),this.isCamera=!0,this.type="Camera",this.matrixWorldInverse=new Lt,this.projectionMatrix=new Lt,this.projectionMatrixInverse=new Lt,this.coordinateSystem=Ii}copy(e,t){return super.copy(e,t),this.matrixWorldInverse.copy(e.matrixWorldInverse),this.projectionMatrix.copy(e.projectionMatrix),this.projectionMatrixInverse.copy(e.projectionMatrixInverse),this.coordinateSystem=e.coordinateSystem,this}getWorldDirection(e){return super.getWorldDirection(e).negate()}updateMatrixWorld(e){super.updateMatrixWorld(e),this.matrixWorldInverse.copy(this.matrixWorld).invert()}updateWorldMatrix(e,t){super.updateWorldMatrix(e,t),this.matrixWorldInverse.copy(this.matrixWorld).invert()}clone(){return new this.constructor().copy(this)}}const $i=new X,gf=new Mt,vf=new Mt;class Jn extends nd{constructor(e=50,t=1,n=.1,i=2e3){super(),this.isPerspectiveCamera=!0,this.type="PerspectiveCamera",this.fov=e,this.zoom=1,this.near=n,this.far=i,this.focus=10,this.aspect=t,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}copy(e,t){return super.copy(e,t),this.fov=e.fov,this.zoom=e.zoom,this.near=e.near,this.far=e.far,this.focus=e.focus,this.aspect=e.aspect,this.view=e.view===null?null:Object.assign({},e.view),this.filmGauge=e.filmGauge,this.filmOffset=e.filmOffset,this}setFocalLength(e){const t=.5*this.getFilmHeight()/e;this.fov=Hc*2*Math.atan(t),this.updateProjectionMatrix()}getFocalLength(){const e=Math.tan(fl*.5*this.fov);return .5*this.getFilmHeight()/e}getEffectiveFOV(){return Hc*2*Math.atan(Math.tan(fl*.5*this.fov)/this.zoom)}getFilmWidth(){return this.filmGauge*Math.min(this.aspect,1)}getFilmHeight(){return this.filmGauge/Math.max(this.aspect,1)}getViewBounds(e,t,n){$i.set(-1,-1,.5).applyMatrix4(this.projectionMatrixInverse),t.set($i.x,$i.y).multiplyScalar(-e/$i.z),$i.set(1,1,.5).applyMatrix4(this.projectionMatrixInverse),n.set($i.x,$i.y).multiplyScalar(-e/$i.z)}getViewSize(e,t){return this.getViewBounds(e,gf,vf),t.subVectors(vf,gf)}setViewOffset(e,t,n,i,s,a){this.aspect=e/t,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=e,this.view.fullHeight=t,this.view.offsetX=n,this.view.offsetY=i,this.view.width=s,this.view.height=a,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const e=this.near;let t=e*Math.tan(fl*.5*this.fov)/this.zoom,n=2*t,i=this.aspect*n,s=-.5*i;const a=this.view;if(this.view!==null&&this.view.enabled){const l=a.fullWidth,c=a.fullHeight;s+=a.offsetX*i/l,t-=a.offsetY*n/c,i*=a.width/l,n*=a.height/c}const o=this.filmOffset;o!==0&&(s+=e*o/this.getFilmWidth()),this.projectionMatrix.makePerspective(s,s+i,t,t-n,e,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(e){const t=super.toJSON(e);return t.object.fov=this.fov,t.object.zoom=this.zoom,t.object.near=this.near,t.object.far=this.far,t.object.focus=this.focus,t.object.aspect=this.aspect,this.view!==null&&(t.object.view=Object.assign({},this.view)),t.object.filmGauge=this.filmGauge,t.object.filmOffset=this.filmOffset,t}}const ss=-90,as=1;class Km extends xn{constructor(e,t,n){super(),this.type="CubeCamera",this.renderTarget=n,this.coordinateSystem=null,this.activeMipmapLevel=0;const i=new Jn(ss,as,e,t);i.layers=this.layers,this.add(i);const s=new Jn(ss,as,e,t);s.layers=this.layers,this.add(s);const a=new Jn(ss,as,e,t);a.layers=this.layers,this.add(a);const o=new Jn(ss,as,e,t);o.layers=this.layers,this.add(o);const l=new Jn(ss,as,e,t);l.layers=this.layers,this.add(l);const c=new Jn(ss,as,e,t);c.layers=this.layers,this.add(c)}updateCoordinateSystem(){const e=this.coordinateSystem,t=this.children.concat(),[n,i,s,a,o,l]=t;for(const c of t)this.remove(c);if(e===Ii)n.up.set(0,1,0),n.lookAt(1,0,0),i.up.set(0,1,0),i.lookAt(-1,0,0),s.up.set(0,0,-1),s.lookAt(0,1,0),a.up.set(0,0,1),a.lookAt(0,-1,0),o.up.set(0,1,0),o.lookAt(0,0,1),l.up.set(0,1,0),l.lookAt(0,0,-1);else if(e===Ho)n.up.set(0,-1,0),n.lookAt(-1,0,0),i.up.set(0,-1,0),i.lookAt(1,0,0),s.up.set(0,0,1),s.lookAt(0,1,0),a.up.set(0,0,-1),a.lookAt(0,-1,0),o.up.set(0,-1,0),o.lookAt(0,0,1),l.up.set(0,-1,0),l.lookAt(0,0,-1);else throw new Error("THREE.CubeCamera.updateCoordinateSystem(): Invalid coordinate system: "+e);for(const c of t)this.add(c),c.updateMatrixWorld()}update(e,t){this.parent===null&&this.updateMatrixWorld();const{renderTarget:n,activeMipmapLevel:i}=this;this.coordinateSystem!==e.coordinateSystem&&(this.coordinateSystem=e.coordinateSystem,this.updateCoordinateSystem());const[s,a,o,l,c,u]=this.children,h=e.getRenderTarget(),d=e.getActiveCubeFace(),f=e.getActiveMipmapLevel(),g=e.xr.enabled;e.xr.enabled=!1;const _=n.texture.generateMipmaps;n.texture.generateMipmaps=!1,e.setRenderTarget(n,0,i),e.render(t,s),e.setRenderTarget(n,1,i),e.render(t,a),e.setRenderTarget(n,2,i),e.render(t,o),e.setRenderTarget(n,3,i),e.render(t,l),e.setRenderTarget(n,4,i),e.render(t,c),n.texture.generateMipmaps=_,e.setRenderTarget(n,5,i),e.render(t,u),e.setRenderTarget(h,d,f),e.xr.enabled=g,n.texture.needsPMREMUpdate=!0}}class id extends bn{constructor(e,t,n,i,s,a,o,l,c,u){e=e!==void 0?e:[],t=t!==void 0?t:Rs,super(e,t,n,i,s,a,o,l,c,u),this.isCubeTexture=!0,this.flipY=!1}get images(){return this.image}set images(e){this.image=e}}class Zm extends Vr{constructor(e=1,t={}){super(e,e,t),this.isWebGLCubeRenderTarget=!0;const n={width:e,height:e,depth:1},i=[n,n,n,n,n,n];this.texture=new id(i,t.mapping,t.wrapS,t.wrapT,t.magFilter,t.minFilter,t.format,t.type,t.anisotropy,t.colorSpace),this.texture.isRenderTargetTexture=!0,this.texture.generateMipmaps=t.generateMipmaps!==void 0?t.generateMipmaps:!1,this.texture.minFilter=t.minFilter!==void 0?t.minFilter:gi}fromEquirectangularTexture(e,t){this.texture.type=t.type,this.texture.colorSpace=t.colorSpace,this.texture.generateMipmaps=t.generateMipmaps,this.texture.minFilter=t.minFilter,this.texture.magFilter=t.magFilter;const n={uniforms:{tEquirect:{value:null}},vertexShader:`

				varying vec3 vWorldDirection;

				vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

					return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

				}

				void main() {

					vWorldDirection = transformDirection( position, modelMatrix );

					#include <begin_vertex>
					#include <project_vertex>

				}
			`,fragmentShader:`

				uniform sampler2D tEquirect;

				varying vec3 vWorldDirection;

				#include <common>

				void main() {

					vec3 direction = normalize( vWorldDirection );

					vec2 sampleUV = equirectUv( direction );

					gl_FragColor = texture2D( tEquirect, sampleUV );

				}
			`},i=new Fa(5,5,5),s=new lr({name:"CubemapFromEquirect",uniforms:Is(n.uniforms),vertexShader:n.vertexShader,fragmentShader:n.fragmentShader,side:Tn,blending:nr});s.uniforms.tEquirect.value=t;const a=new Ui(i,s),o=t.minFilter;return t.minFilter===Dr&&(t.minFilter=gi),new Km(1,10,this).update(e,a),t.minFilter=o,a.geometry.dispose(),a.material.dispose(),this}clear(e,t,n,i){const s=e.getRenderTarget();for(let a=0;a<6;a++)e.setRenderTarget(this,a),e.clear(t,n,i);e.setRenderTarget(s)}}class jm extends xn{constructor(){super(),this.isScene=!0,this.type="Scene",this.background=null,this.environment=null,this.fog=null,this.backgroundBlurriness=0,this.backgroundIntensity=1,this.backgroundRotation=new ki,this.environmentIntensity=1,this.environmentRotation=new ki,this.overrideMaterial=null,typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}copy(e,t){return super.copy(e,t),e.background!==null&&(this.background=e.background.clone()),e.environment!==null&&(this.environment=e.environment.clone()),e.fog!==null&&(this.fog=e.fog.clone()),this.backgroundBlurriness=e.backgroundBlurriness,this.backgroundIntensity=e.backgroundIntensity,this.backgroundRotation.copy(e.backgroundRotation),this.environmentIntensity=e.environmentIntensity,this.environmentRotation.copy(e.environmentRotation),e.overrideMaterial!==null&&(this.overrideMaterial=e.overrideMaterial.clone()),this.matrixAutoUpdate=e.matrixAutoUpdate,this}toJSON(e){const t=super.toJSON(e);return this.fog!==null&&(t.object.fog=this.fog.toJSON()),this.backgroundBlurriness>0&&(t.object.backgroundBlurriness=this.backgroundBlurriness),this.backgroundIntensity!==1&&(t.object.backgroundIntensity=this.backgroundIntensity),t.object.backgroundRotation=this.backgroundRotation.toArray(),this.environmentIntensity!==1&&(t.object.environmentIntensity=this.environmentIntensity),t.object.environmentRotation=this.environmentRotation.toArray(),t}}const Ll=new X,Jm=new X,Qm=new qe;class Er{constructor(e=new X(1,0,0),t=0){this.isPlane=!0,this.normal=e,this.constant=t}set(e,t){return this.normal.copy(e),this.constant=t,this}setComponents(e,t,n,i){return this.normal.set(e,t,n),this.constant=i,this}setFromNormalAndCoplanarPoint(e,t){return this.normal.copy(e),this.constant=-t.dot(this.normal),this}setFromCoplanarPoints(e,t,n){const i=Ll.subVectors(n,t).cross(Jm.subVectors(e,t)).normalize();return this.setFromNormalAndCoplanarPoint(i,e),this}copy(e){return this.normal.copy(e.normal),this.constant=e.constant,this}normalize(){const e=1/this.normal.length();return this.normal.multiplyScalar(e),this.constant*=e,this}negate(){return this.constant*=-1,this.normal.negate(),this}distanceToPoint(e){return this.normal.dot(e)+this.constant}distanceToSphere(e){return this.distanceToPoint(e.center)-e.radius}projectPoint(e,t){return t.copy(e).addScaledVector(this.normal,-this.distanceToPoint(e))}intersectLine(e,t){const n=e.delta(Ll),i=this.normal.dot(n);if(i===0)return this.distanceToPoint(e.start)===0?t.copy(e.start):null;const s=-(e.start.dot(this.normal)+this.constant)/i;return s<0||s>1?null:t.copy(e.start).addScaledVector(n,s)}intersectsLine(e){const t=this.distanceToPoint(e.start),n=this.distanceToPoint(e.end);return t<0&&n>0||n<0&&t>0}intersectsBox(e){return e.intersectsPlane(this)}intersectsSphere(e){return e.intersectsPlane(this)}coplanarPoint(e){return e.copy(this.normal).multiplyScalar(-this.constant)}applyMatrix4(e,t){const n=t||Qm.getNormalMatrix(e),i=this.coplanarPoint(Ll).applyMatrix4(e),s=this.normal.applyMatrix3(n).normalize();return this.constant=-i.dot(s),this}translate(e){return this.constant-=e.dot(this.normal),this}equals(e){return e.normal.equals(this.normal)&&e.constant===this.constant}clone(){return new this.constructor().copy(this)}}const vr=new Na,to=new X;class rd{constructor(e=new Er,t=new Er,n=new Er,i=new Er,s=new Er,a=new Er){this.planes=[e,t,n,i,s,a]}set(e,t,n,i,s,a){const o=this.planes;return o[0].copy(e),o[1].copy(t),o[2].copy(n),o[3].copy(i),o[4].copy(s),o[5].copy(a),this}copy(e){const t=this.planes;for(let n=0;n<6;n++)t[n].copy(e.planes[n]);return this}setFromProjectionMatrix(e,t=Ii){const n=this.planes,i=e.elements,s=i[0],a=i[1],o=i[2],l=i[3],c=i[4],u=i[5],h=i[6],d=i[7],f=i[8],g=i[9],_=i[10],m=i[11],p=i[12],T=i[13],E=i[14],x=i[15];if(n[0].setComponents(l-s,d-c,m-f,x-p).normalize(),n[1].setComponents(l+s,d+c,m+f,x+p).normalize(),n[2].setComponents(l+a,d+u,m+g,x+T).normalize(),n[3].setComponents(l-a,d-u,m-g,x-T).normalize(),n[4].setComponents(l-o,d-h,m-_,x-E).normalize(),t===Ii)n[5].setComponents(l+o,d+h,m+_,x+E).normalize();else if(t===Ho)n[5].setComponents(o,h,_,E).normalize();else throw new Error("THREE.Frustum.setFromProjectionMatrix(): Invalid coordinate system: "+t);return this}intersectsObject(e){if(e.boundingSphere!==void 0)e.boundingSphere===null&&e.computeBoundingSphere(),vr.copy(e.boundingSphere).applyMatrix4(e.matrixWorld);else{const t=e.geometry;t.boundingSphere===null&&t.computeBoundingSphere(),vr.copy(t.boundingSphere).applyMatrix4(e.matrixWorld)}return this.intersectsSphere(vr)}intersectsSprite(e){return vr.center.set(0,0,0),vr.radius=.7071067811865476,vr.applyMatrix4(e.matrixWorld),this.intersectsSphere(vr)}intersectsSphere(e){const t=this.planes,n=e.center,i=-e.radius;for(let s=0;s<6;s++)if(t[s].distanceToPoint(n)<i)return!1;return!0}intersectsBox(e){const t=this.planes;for(let n=0;n<6;n++){const i=t[n];if(to.x=i.normal.x>0?e.max.x:e.min.x,to.y=i.normal.y>0?e.max.y:e.min.y,to.z=i.normal.z>0?e.max.z:e.min.z,i.distanceToPoint(to)<0)return!1}return!0}containsPoint(e){const t=this.planes;for(let n=0;n<6;n++)if(t[n].distanceToPoint(e)<0)return!1;return!0}clone(){return new this.constructor().copy(this)}}class sd extends Vs{constructor(e){super(),this.isLineBasicMaterial=!0,this.type="LineBasicMaterial",this.color=new nt(16777215),this.map=null,this.linewidth=1,this.linecap="round",this.linejoin="round",this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.color.copy(e.color),this.map=e.map,this.linewidth=e.linewidth,this.linecap=e.linecap,this.linejoin=e.linejoin,this.fog=e.fog,this}}const Go=new X,Wo=new X,xf=new Lt,Zs=new Su,no=new Na,Il=new X,Mf=new X;class e_ extends xn{constructor(e=new hi,t=new sd){super(),this.isLine=!0,this.type="Line",this.geometry=e,this.material=t,this.updateMorphTargets()}copy(e,t){return super.copy(e,t),this.material=Array.isArray(e.material)?e.material.slice():e.material,this.geometry=e.geometry,this}computeLineDistances(){const e=this.geometry;if(e.index===null){const t=e.attributes.position,n=[0];for(let i=1,s=t.count;i<s;i++)Go.fromBufferAttribute(t,i-1),Wo.fromBufferAttribute(t,i),n[i]=n[i-1],n[i]+=Go.distanceTo(Wo);e.setAttribute("lineDistance",new Oi(n,1))}else console.warn("THREE.Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}raycast(e,t){const n=this.geometry,i=this.matrixWorld,s=e.params.Line.threshold,a=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),no.copy(n.boundingSphere),no.applyMatrix4(i),no.radius+=s,e.ray.intersectsSphere(no)===!1)return;xf.copy(i).invert(),Zs.copy(e.ray).applyMatrix4(xf);const o=s/((this.scale.x+this.scale.y+this.scale.z)/3),l=o*o,c=this.isLineSegments?2:1,u=n.index,d=n.attributes.position;if(u!==null){const f=Math.max(0,a.start),g=Math.min(u.count,a.start+a.count);for(let _=f,m=g-1;_<m;_+=c){const p=u.getX(_),T=u.getX(_+1),E=io(this,e,Zs,l,p,T);E&&t.push(E)}if(this.isLineLoop){const _=u.getX(g-1),m=u.getX(f),p=io(this,e,Zs,l,_,m);p&&t.push(p)}}else{const f=Math.max(0,a.start),g=Math.min(d.count,a.start+a.count);for(let _=f,m=g-1;_<m;_+=c){const p=io(this,e,Zs,l,_,_+1);p&&t.push(p)}if(this.isLineLoop){const _=io(this,e,Zs,l,g-1,f);_&&t.push(_)}}}updateMorphTargets(){const t=this.geometry.morphAttributes,n=Object.keys(t);if(n.length>0){const i=t[n[0]];if(i!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,a=i.length;s<a;s++){const o=i[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[o]=s}}}}}function io(r,e,t,n,i,s){const a=r.geometry.attributes.position;if(Go.fromBufferAttribute(a,i),Wo.fromBufferAttribute(a,s),t.distanceSqToSegment(Go,Wo,Il,Mf)>n)return;Il.applyMatrix4(r.matrixWorld);const l=e.ray.origin.distanceTo(Il);if(!(l<e.near||l>e.far))return{distance:l,point:Mf.clone().applyMatrix4(r.matrixWorld),index:i,face:null,faceIndex:null,barycoord:null,object:r}}const Sf=new X,yf=new X;class t_ extends e_{constructor(e,t){super(e,t),this.isLineSegments=!0,this.type="LineSegments"}computeLineDistances(){const e=this.geometry;if(e.index===null){const t=e.attributes.position,n=[];for(let i=0,s=t.count;i<s;i+=2)Sf.fromBufferAttribute(t,i),yf.fromBufferAttribute(t,i+1),n[i]=i===0?0:n[i-1],n[i+1]=n[i]+Sf.distanceTo(yf);e.setAttribute("lineDistance",new Oi(n,1))}else console.warn("THREE.LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}}class ad extends Vs{constructor(e){super(),this.isPointsMaterial=!0,this.type="PointsMaterial",this.color=new nt(16777215),this.map=null,this.alphaMap=null,this.size=1,this.sizeAttenuation=!0,this.fog=!0,this.setValues(e)}copy(e){return super.copy(e),this.color.copy(e.color),this.map=e.map,this.alphaMap=e.alphaMap,this.size=e.size,this.sizeAttenuation=e.sizeAttenuation,this.fog=e.fog,this}}const Ef=new Lt,Vc=new Su,ro=new Na,so=new X;class n_ extends xn{constructor(e=new hi,t=new ad){super(),this.isPoints=!0,this.type="Points",this.geometry=e,this.material=t,this.updateMorphTargets()}copy(e,t){return super.copy(e,t),this.material=Array.isArray(e.material)?e.material.slice():e.material,this.geometry=e.geometry,this}raycast(e,t){const n=this.geometry,i=this.matrixWorld,s=e.params.Points.threshold,a=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),ro.copy(n.boundingSphere),ro.applyMatrix4(i),ro.radius+=s,e.ray.intersectsSphere(ro)===!1)return;Ef.copy(i).invert(),Vc.copy(e.ray).applyMatrix4(Ef);const o=s/((this.scale.x+this.scale.y+this.scale.z)/3),l=o*o,c=n.index,h=n.attributes.position;if(c!==null){const d=Math.max(0,a.start),f=Math.min(c.count,a.start+a.count);for(let g=d,_=f;g<_;g++){const m=c.getX(g);so.fromBufferAttribute(h,m),Tf(so,m,l,i,e,t,this)}}else{const d=Math.max(0,a.start),f=Math.min(h.count,a.start+a.count);for(let g=d,_=f;g<_;g++)so.fromBufferAttribute(h,g),Tf(so,g,l,i,e,t,this)}}updateMorphTargets(){const t=this.geometry.morphAttributes,n=Object.keys(t);if(n.length>0){const i=t[n[0]];if(i!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let s=0,a=i.length;s<a;s++){const o=i[s].name||String(s);this.morphTargetInfluences.push(0),this.morphTargetDictionary[o]=s}}}}}function Tf(r,e,t,n,i,s,a){const o=Vc.distanceSqToPoint(r);if(o<t){const l=new X;Vc.closestPointToPoint(r,l),l.applyMatrix4(n);const c=i.ray.origin.distanceTo(l);if(c<i.near||c>i.far)return;s.push({distance:c,distanceToRay:Math.sqrt(o),point:l,index:e,face:null,faceIndex:null,barycoord:null,object:a})}}class ao extends xn{constructor(){super(),this.isGroup=!0,this.type="Group"}}class od extends bn{constructor(e,t,n,i,s,a,o,l,c,u=xs){if(u!==xs&&u!==Ds)throw new Error("DepthTexture format must be either THREE.DepthFormat or THREE.DepthStencilFormat");n===void 0&&u===xs&&(n=Hr),n===void 0&&u===Ds&&(n=Ps),super(null,i,s,a,o,l,u,n,c),this.isDepthTexture=!0,this.image={width:e,height:t},this.magFilter=o!==void 0?o:fi,this.minFilter=l!==void 0?l:fi,this.flipY=!1,this.generateMipmaps=!1,this.compareFunction=null}copy(e){return super.copy(e),this.compareFunction=e.compareFunction,this}toJSON(e){const t=super.toJSON(e);return this.compareFunction!==null&&(t.compareFunction=this.compareFunction),t}}class il extends hi{constructor(e=1,t=1,n=1,i=1){super(),this.type="PlaneGeometry",this.parameters={width:e,height:t,widthSegments:n,heightSegments:i};const s=e/2,a=t/2,o=Math.floor(n),l=Math.floor(i),c=o+1,u=l+1,h=e/o,d=t/l,f=[],g=[],_=[],m=[];for(let p=0;p<u;p++){const T=p*d-a;for(let E=0;E<c;E++){const x=E*h-s;g.push(x,-T,0),_.push(0,0,1),m.push(E/o),m.push(1-p/l)}}for(let p=0;p<l;p++)for(let T=0;T<o;T++){const E=T+c*p,x=T+c*(p+1),R=T+1+c*(p+1),w=T+1+c*p;f.push(E,x,w),f.push(x,R,w)}this.setIndex(f),this.setAttribute("position",new Oi(g,3)),this.setAttribute("normal",new Oi(_,3)),this.setAttribute("uv",new Oi(m,2))}copy(e){return super.copy(e),this.parameters=Object.assign({},e.parameters),this}static fromJSON(e){return new il(e.width,e.height,e.widthSegments,e.heightSegments)}}class i_ extends Vs{constructor(e){super(),this.isMeshDepthMaterial=!0,this.type="MeshDepthMaterial",this.depthPacking=dm,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.setValues(e)}copy(e){return super.copy(e),this.depthPacking=e.depthPacking,this.map=e.map,this.alphaMap=e.alphaMap,this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this}}class r_ extends Vs{constructor(e){super(),this.isMeshDistanceMaterial=!0,this.type="MeshDistanceMaterial",this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.setValues(e)}copy(e){return super.copy(e),this.map=e.map,this.alphaMap=e.alphaMap,this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this}}class s_ extends nd{constructor(e=-1,t=1,n=1,i=-1,s=.1,a=2e3){super(),this.isOrthographicCamera=!0,this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=e,this.right=t,this.top=n,this.bottom=i,this.near=s,this.far=a,this.updateProjectionMatrix()}copy(e,t){return super.copy(e,t),this.left=e.left,this.right=e.right,this.top=e.top,this.bottom=e.bottom,this.near=e.near,this.far=e.far,this.zoom=e.zoom,this.view=e.view===null?null:Object.assign({},e.view),this}setViewOffset(e,t,n,i,s,a){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=e,this.view.fullHeight=t,this.view.offsetX=n,this.view.offsetY=i,this.view.width=s,this.view.height=a,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const e=(this.right-this.left)/(2*this.zoom),t=(this.top-this.bottom)/(2*this.zoom),n=(this.right+this.left)/2,i=(this.top+this.bottom)/2;let s=n-e,a=n+e,o=i+t,l=i-t;if(this.view!==null&&this.view.enabled){const c=(this.right-this.left)/this.view.fullWidth/this.zoom,u=(this.top-this.bottom)/this.view.fullHeight/this.zoom;s+=c*this.view.offsetX,a=s+c*this.view.width,o-=u*this.view.offsetY,l=o-u*this.view.height}this.projectionMatrix.makeOrthographic(s,a,o,l,this.near,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(e){const t=super.toJSON(e);return t.object.zoom=this.zoom,t.object.left=this.left,t.object.right=this.right,t.object.top=this.top,t.object.bottom=this.bottom,t.object.near=this.near,t.object.far=this.far,this.view!==null&&(t.object.view=Object.assign({},this.view)),t}}class a_ extends Jn{constructor(e=[]){super(),this.isArrayCamera=!0,this.cameras=e}}class o_{constructor(e=!0){this.autoStart=e,this.startTime=0,this.oldTime=0,this.elapsedTime=0,this.running=!1}start(){this.startTime=bf(),this.oldTime=this.startTime,this.elapsedTime=0,this.running=!0}stop(){this.getElapsedTime(),this.running=!1,this.autoStart=!1}getElapsedTime(){return this.getDelta(),this.elapsedTime}getDelta(){let e=0;if(this.autoStart&&!this.running)return this.start(),0;if(this.running){const t=bf();e=(t-this.oldTime)/1e3,this.oldTime=t,this.elapsedTime+=e}return e}}function bf(){return performance.now()}function Af(r,e,t,n){const i=l_(n);switch(t){case zh:return r*e;case Hh:return r*e;case Vh:return r*e*2;case Gh:return r*e/i.components*i.byteLength;case vu:return r*e/i.components*i.byteLength;case Wh:return r*e*2/i.components*i.byteLength;case xu:return r*e*2/i.components*i.byteLength;case kh:return r*e*3/i.components*i.byteLength;case ui:return r*e*4/i.components*i.byteLength;case Mu:return r*e*4/i.components*i.byteLength;case To:case bo:return Math.floor((r+3)/4)*Math.floor((e+3)/4)*8;case Ao:case wo:return Math.floor((r+3)/4)*Math.floor((e+3)/4)*16;case _c:case vc:return Math.max(r,16)*Math.max(e,8)/4;case mc:case gc:return Math.max(r,8)*Math.max(e,8)/2;case xc:case Mc:return Math.floor((r+3)/4)*Math.floor((e+3)/4)*8;case Sc:return Math.floor((r+3)/4)*Math.floor((e+3)/4)*16;case yc:return Math.floor((r+3)/4)*Math.floor((e+3)/4)*16;case Ec:return Math.floor((r+4)/5)*Math.floor((e+3)/4)*16;case Tc:return Math.floor((r+4)/5)*Math.floor((e+4)/5)*16;case bc:return Math.floor((r+5)/6)*Math.floor((e+4)/5)*16;case Ac:return Math.floor((r+5)/6)*Math.floor((e+5)/6)*16;case wc:return Math.floor((r+7)/8)*Math.floor((e+4)/5)*16;case Rc:return Math.floor((r+7)/8)*Math.floor((e+5)/6)*16;case Cc:return Math.floor((r+7)/8)*Math.floor((e+7)/8)*16;case Pc:return Math.floor((r+9)/10)*Math.floor((e+4)/5)*16;case Dc:return Math.floor((r+9)/10)*Math.floor((e+5)/6)*16;case Lc:return Math.floor((r+9)/10)*Math.floor((e+7)/8)*16;case Ic:return Math.floor((r+9)/10)*Math.floor((e+9)/10)*16;case Uc:return Math.floor((r+11)/12)*Math.floor((e+9)/10)*16;case Nc:return Math.floor((r+11)/12)*Math.floor((e+11)/12)*16;case Ro:case Fc:case Oc:return Math.ceil(r/4)*Math.ceil(e/4)*16;case Xh:case Bc:return Math.ceil(r/4)*Math.ceil(e/4)*8;case zc:case kc:return Math.ceil(r/4)*Math.ceil(e/4)*16}throw new Error(`Unable to determine texture byte length for ${t} format.`)}function l_(r){switch(r){case zi:case Fh:return{byteLength:1,components:1};case Sa:case Oh:case Da:return{byteLength:2,components:1};case _u:case gu:return{byteLength:2,components:4};case Hr:case mu:case Li:return{byteLength:4,components:1};case Bh:return{byteLength:4,components:3}}throw new Error(`Unknown texture type ${r}.`)}typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("register",{detail:{revision:pu}}));typeof window<"u"&&(window.__THREE__?console.warn("WARNING: Multiple instances of Three.js being imported."):window.__THREE__=pu);/**
 * @license
 * Copyright 2010-2024 Three.js Authors
 * SPDX-License-Identifier: MIT
 */function ld(){let r=null,e=!1,t=null,n=null;function i(s,a){t(s,a),n=r.requestAnimationFrame(i)}return{start:function(){e!==!0&&t!==null&&(n=r.requestAnimationFrame(i),e=!0)},stop:function(){r.cancelAnimationFrame(n),e=!1},setAnimationLoop:function(s){t=s},setContext:function(s){r=s}}}function c_(r){const e=new WeakMap;function t(o,l){const c=o.array,u=o.usage,h=c.byteLength,d=r.createBuffer();r.bindBuffer(l,d),r.bufferData(l,c,u),o.onUploadCallback();let f;if(c instanceof Float32Array)f=r.FLOAT;else if(c instanceof Uint16Array)o.isFloat16BufferAttribute?f=r.HALF_FLOAT:f=r.UNSIGNED_SHORT;else if(c instanceof Int16Array)f=r.SHORT;else if(c instanceof Uint32Array)f=r.UNSIGNED_INT;else if(c instanceof Int32Array)f=r.INT;else if(c instanceof Int8Array)f=r.BYTE;else if(c instanceof Uint8Array)f=r.UNSIGNED_BYTE;else if(c instanceof Uint8ClampedArray)f=r.UNSIGNED_BYTE;else throw new Error("THREE.WebGLAttributes: Unsupported buffer data format: "+c);return{buffer:d,type:f,bytesPerElement:c.BYTES_PER_ELEMENT,version:o.version,size:h}}function n(o,l,c){const u=l.array,h=l.updateRanges;if(r.bindBuffer(c,o),h.length===0)r.bufferSubData(c,0,u);else{h.sort((f,g)=>f.start-g.start);let d=0;for(let f=1;f<h.length;f++){const g=h[d],_=h[f];_.start<=g.start+g.count+1?g.count=Math.max(g.count,_.start+_.count-g.start):(++d,h[d]=_)}h.length=d+1;for(let f=0,g=h.length;f<g;f++){const _=h[f];r.bufferSubData(c,_.start*u.BYTES_PER_ELEMENT,u,_.start,_.count)}l.clearUpdateRanges()}l.onUploadCallback()}function i(o){return o.isInterleavedBufferAttribute&&(o=o.data),e.get(o)}function s(o){o.isInterleavedBufferAttribute&&(o=o.data);const l=e.get(o);l&&(r.deleteBuffer(l.buffer),e.delete(o))}function a(o,l){if(o.isInterleavedBufferAttribute&&(o=o.data),o.isGLBufferAttribute){const u=e.get(o);(!u||u.version<o.version)&&e.set(o,{buffer:o.buffer,type:o.type,bytesPerElement:o.elementSize,version:o.version});return}const c=e.get(o);if(c===void 0)e.set(o,t(o,l));else if(c.version<o.version){if(c.size!==o.array.byteLength)throw new Error("THREE.WebGLAttributes: The size of the buffer attribute's array buffer does not match the original size. Resizing buffer attributes is not supported.");n(c.buffer,o,l),c.version=o.version}}return{get:i,remove:s,update:a}}var u_=`#ifdef USE_ALPHAHASH
	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif`,f_=`#ifdef USE_ALPHAHASH
	const float ALPHA_HASH_SCALE = 0.05;
	float hash2D( vec2 value ) {
		return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );
	}
	float hash3D( vec3 value ) {
		return hash2D( vec2( hash2D( value.xy ), value.z ) );
	}
	float getAlphaHashThreshold( vec3 position ) {
		float maxDeriv = max(
			length( dFdx( position.xyz ) ),
			length( dFdy( position.xyz ) )
		);
		float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );
		vec2 pixScales = vec2(
			exp2( floor( log2( pixScale ) ) ),
			exp2( ceil( log2( pixScale ) ) )
		);
		vec2 alpha = vec2(
			hash3D( floor( pixScales.x * position.xyz ) ),
			hash3D( floor( pixScales.y * position.xyz ) )
		);
		float lerpFactor = fract( log2( pixScale ) );
		float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;
		float a = min( lerpFactor, 1.0 - lerpFactor );
		vec3 cases = vec3(
			x * x / ( 2.0 * a * ( 1.0 - a ) ),
			( x - 0.5 * a ) / ( 1.0 - a ),
			1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
		);
		float threshold = ( x < ( 1.0 - a ) )
			? ( ( x < a ) ? cases.x : cases.y )
			: cases.z;
		return clamp( threshold , 1.0e-6, 1.0 );
	}
#endif`,h_=`#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif`,d_=`#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,p_=`#ifdef USE_ALPHATEST
	#ifdef ALPHA_TO_COVERAGE
	diffuseColor.a = smoothstep( alphaTest, alphaTest + fwidth( diffuseColor.a ), diffuseColor.a );
	if ( diffuseColor.a == 0.0 ) discard;
	#else
	if ( diffuseColor.a < alphaTest ) discard;
	#endif
#endif`,m_=`#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif`,__=`#ifdef USE_AOMAP
	float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;
	reflectedLight.indirectDiffuse *= ambientOcclusion;
	#if defined( USE_CLEARCOAT ) 
		clearcoatSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_SHEEN ) 
		sheenSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD )
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );
	#endif
#endif`,g_=`#ifdef USE_AOMAP
	uniform sampler2D aoMap;
	uniform float aoMapIntensity;
#endif`,v_=`#ifdef USE_BATCHING
	#if ! defined( GL_ANGLE_multi_draw )
	#define gl_DrawID _gl_DrawID
	uniform int _gl_DrawID;
	#endif
	uniform highp sampler2D batchingTexture;
	uniform highp usampler2D batchingIdTexture;
	mat4 getBatchingMatrix( const in float i ) {
		int size = textureSize( batchingTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
	float getIndirectIndex( const in int i ) {
		int size = textureSize( batchingIdTexture, 0 ).x;
		int x = i % size;
		int y = i / size;
		return float( texelFetch( batchingIdTexture, ivec2( x, y ), 0 ).r );
	}
#endif
#ifdef USE_BATCHING_COLOR
	uniform sampler2D batchingColorTexture;
	vec3 getBatchingColor( const in float i ) {
		int size = textureSize( batchingColorTexture, 0 ).x;
		int j = int( i );
		int x = j % size;
		int y = j / size;
		return texelFetch( batchingColorTexture, ivec2( x, y ), 0 ).rgb;
	}
#endif`,x_=`#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( getIndirectIndex( gl_DrawID ) );
#endif`,M_=`vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
	vPosition = vec3( position );
#endif`,S_=`vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
	vec3 objectTangent = vec3( tangent.xyz );
#endif`,y_=`float G_BlinnPhong_Implicit( ) {
	return 0.25;
}
float D_BlinnPhong( const in float shininess, const in float dotNH ) {
	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
}
vec3 BRDF_BlinnPhong( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float shininess ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( specularColor, 1.0, dotVH );
	float G = G_BlinnPhong_Implicit( );
	float D = D_BlinnPhong( shininess, dotNH );
	return F * ( G * D );
} // validated`,E_=`#ifdef USE_IRIDESCENCE
	const mat3 XYZ_TO_REC709 = mat3(
		 3.2404542, -0.9692660,  0.0556434,
		-1.5371385,  1.8760108, -0.2040259,
		-0.4985314,  0.0415560,  1.0572252
	);
	vec3 Fresnel0ToIor( vec3 fresnel0 ) {
		vec3 sqrtF0 = sqrt( fresnel0 );
		return ( vec3( 1.0 ) + sqrtF0 ) / ( vec3( 1.0 ) - sqrtF0 );
	}
	vec3 IorToFresnel0( vec3 transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - vec3( incidentIor ) ) / ( transmittedIor + vec3( incidentIor ) ) );
	}
	float IorToFresnel0( float transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - incidentIor ) / ( transmittedIor + incidentIor ));
	}
	vec3 evalSensitivity( float OPD, vec3 shift ) {
		float phase = 2.0 * PI * OPD * 1.0e-9;
		vec3 val = vec3( 5.4856e-13, 4.4201e-13, 5.2481e-13 );
		vec3 pos = vec3( 1.6810e+06, 1.7953e+06, 2.2084e+06 );
		vec3 var = vec3( 4.3278e+09, 9.3046e+09, 6.6121e+09 );
		vec3 xyz = val * sqrt( 2.0 * PI * var ) * cos( pos * phase + shift ) * exp( - pow2( phase ) * var );
		xyz.x += 9.7470e-14 * sqrt( 2.0 * PI * 4.5282e+09 ) * cos( 2.2399e+06 * phase + shift[ 0 ] ) * exp( - 4.5282e+09 * pow2( phase ) );
		xyz /= 1.0685e-7;
		vec3 rgb = XYZ_TO_REC709 * xyz;
		return rgb;
	}
	vec3 evalIridescence( float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0 ) {
		vec3 I;
		float iridescenceIOR = mix( outsideIOR, eta2, smoothstep( 0.0, 0.03, thinFilmThickness ) );
		float sinTheta2Sq = pow2( outsideIOR / iridescenceIOR ) * ( 1.0 - pow2( cosTheta1 ) );
		float cosTheta2Sq = 1.0 - sinTheta2Sq;
		if ( cosTheta2Sq < 0.0 ) {
			return vec3( 1.0 );
		}
		float cosTheta2 = sqrt( cosTheta2Sq );
		float R0 = IorToFresnel0( iridescenceIOR, outsideIOR );
		float R12 = F_Schlick( R0, 1.0, cosTheta1 );
		float T121 = 1.0 - R12;
		float phi12 = 0.0;
		if ( iridescenceIOR < outsideIOR ) phi12 = PI;
		float phi21 = PI - phi12;
		vec3 baseIOR = Fresnel0ToIor( clamp( baseF0, 0.0, 0.9999 ) );		vec3 R1 = IorToFresnel0( baseIOR, iridescenceIOR );
		vec3 R23 = F_Schlick( R1, 1.0, cosTheta2 );
		vec3 phi23 = vec3( 0.0 );
		if ( baseIOR[ 0 ] < iridescenceIOR ) phi23[ 0 ] = PI;
		if ( baseIOR[ 1 ] < iridescenceIOR ) phi23[ 1 ] = PI;
		if ( baseIOR[ 2 ] < iridescenceIOR ) phi23[ 2 ] = PI;
		float OPD = 2.0 * iridescenceIOR * thinFilmThickness * cosTheta2;
		vec3 phi = vec3( phi21 ) + phi23;
		vec3 R123 = clamp( R12 * R23, 1e-5, 0.9999 );
		vec3 r123 = sqrt( R123 );
		vec3 Rs = pow2( T121 ) * R23 / ( vec3( 1.0 ) - R123 );
		vec3 C0 = R12 + Rs;
		I = C0;
		vec3 Cm = Rs - T121;
		for ( int m = 1; m <= 2; ++ m ) {
			Cm *= r123;
			vec3 Sm = 2.0 * evalSensitivity( float( m ) * OPD, float( m ) * phi );
			I += Cm * Sm;
		}
		return max( I, vec3( 0.0 ) );
	}
#endif`,T_=`#ifdef USE_BUMPMAP
	uniform sampler2D bumpMap;
	uniform float bumpScale;
	vec2 dHdxy_fwd() {
		vec2 dSTdx = dFdx( vBumpMapUv );
		vec2 dSTdy = dFdy( vBumpMapUv );
		float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;
		return vec2( dBx, dBy );
	}
	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {
		vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
		vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
		vec3 vN = surf_norm;
		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );
		float fDet = dot( vSigmaX, R1 ) * faceDirection;
		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );
	}
#endif`,b_=`#if NUM_CLIPPING_PLANES > 0
	vec4 plane;
	#ifdef ALPHA_TO_COVERAGE
		float distanceToPlane, distanceGradient;
		float clipOpacity = 1.0;
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
			distanceGradient = fwidth( distanceToPlane ) / 2.0;
			clipOpacity *= smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			if ( clipOpacity == 0.0 ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			float unionClipOpacity = 1.0;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
				distanceGradient = fwidth( distanceToPlane ) / 2.0;
				unionClipOpacity *= 1.0 - smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			}
			#pragma unroll_loop_end
			clipOpacity *= 1.0 - unionClipOpacity;
		#endif
		diffuseColor.a *= clipOpacity;
		if ( diffuseColor.a == 0.0 ) discard;
	#else
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			if ( dot( vClipPosition, plane.xyz ) > plane.w ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			bool clipped = true;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				clipped = ( dot( vClipPosition, plane.xyz ) > plane.w ) && clipped;
			}
			#pragma unroll_loop_end
			if ( clipped ) discard;
		#endif
	#endif
#endif`,A_=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];
#endif`,w_=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
#endif`,R_=`#if NUM_CLIPPING_PLANES > 0
	vClipPosition = - mvPosition.xyz;
#endif`,C_=`#if defined( USE_COLOR_ALPHA )
	diffuseColor *= vColor;
#elif defined( USE_COLOR )
	diffuseColor.rgb *= vColor;
#endif`,P_=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR )
	varying vec3 vColor;
#endif`,D_=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	varying vec3 vColor;
#endif`,L_=`#if defined( USE_COLOR_ALPHA )
	vColor = vec4( 1.0 );
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	vColor = vec3( 1.0 );
#endif
#ifdef USE_COLOR
	vColor *= color;
#endif
#ifdef USE_INSTANCING_COLOR
	vColor.xyz *= instanceColor.xyz;
#endif
#ifdef USE_BATCHING_COLOR
	vec3 batchingColor = getBatchingColor( getIndirectIndex( gl_DrawID ) );
	vColor.xyz *= batchingColor.xyz;
#endif`,I_=`#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6
#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )
float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333 ) ); }
highp float rand( const in vec2 uv ) {
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract( sin( sn ) * c );
}
#ifdef HIGH_PRECISION
	float precisionSafeLength( vec3 v ) { return length( v ); }
#else
	float precisionSafeLength( vec3 v ) {
		float maxComponent = max3( abs( v ) );
		return length( v / maxComponent ) * maxComponent;
	}
#endif
struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};
struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};
#ifdef USE_ALPHAHASH
	varying vec3 vPosition;
#endif
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
}
mat3 transposeMat3( const in mat3 m ) {
	mat3 tmp;
	tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
	tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
	tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
	return tmp;
}
bool isPerspectiveMatrix( mat4 m ) {
	return m[ 2 ][ 3 ] == - 1.0;
}
vec2 equirectUv( in vec3 dir ) {
	float u = atan( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;
	float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
	return vec2( u, v );
}
vec3 BRDF_Lambert( const in vec3 diffuseColor ) {
	return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
}
float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
} // validated`,U_=`#ifdef ENVMAP_TYPE_CUBE_UV
	#define cubeUV_minMipLevel 4.0
	#define cubeUV_minTileSize 16.0
	float getFace( vec3 direction ) {
		vec3 absDirection = abs( direction );
		float face = - 1.0;
		if ( absDirection.x > absDirection.z ) {
			if ( absDirection.x > absDirection.y )
				face = direction.x > 0.0 ? 0.0 : 3.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		} else {
			if ( absDirection.z > absDirection.y )
				face = direction.z > 0.0 ? 2.0 : 5.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		}
		return face;
	}
	vec2 getUV( vec3 direction, float face ) {
		vec2 uv;
		if ( face == 0.0 ) {
			uv = vec2( direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 1.0 ) {
			uv = vec2( - direction.x, - direction.z ) / abs( direction.y );
		} else if ( face == 2.0 ) {
			uv = vec2( - direction.x, direction.y ) / abs( direction.z );
		} else if ( face == 3.0 ) {
			uv = vec2( - direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 4.0 ) {
			uv = vec2( - direction.x, direction.z ) / abs( direction.y );
		} else {
			uv = vec2( direction.x, direction.y ) / abs( direction.z );
		}
		return 0.5 * ( uv + 1.0 );
	}
	vec3 bilinearCubeUV( sampler2D envMap, vec3 direction, float mipInt ) {
		float face = getFace( direction );
		float filterInt = max( cubeUV_minMipLevel - mipInt, 0.0 );
		mipInt = max( mipInt, cubeUV_minMipLevel );
		float faceSize = exp2( mipInt );
		highp vec2 uv = getUV( direction, face ) * ( faceSize - 2.0 ) + 1.0;
		if ( face > 2.0 ) {
			uv.y += faceSize;
			face -= 3.0;
		}
		uv.x += face * faceSize;
		uv.x += filterInt * 3.0 * cubeUV_minTileSize;
		uv.y += 4.0 * ( exp2( CUBEUV_MAX_MIP ) - faceSize );
		uv.x *= CUBEUV_TEXEL_WIDTH;
		uv.y *= CUBEUV_TEXEL_HEIGHT;
		#ifdef texture2DGradEXT
			return texture2DGradEXT( envMap, uv, vec2( 0.0 ), vec2( 0.0 ) ).rgb;
		#else
			return texture2D( envMap, uv ).rgb;
		#endif
	}
	#define cubeUV_r0 1.0
	#define cubeUV_m0 - 2.0
	#define cubeUV_r1 0.8
	#define cubeUV_m1 - 1.0
	#define cubeUV_r4 0.4
	#define cubeUV_m4 2.0
	#define cubeUV_r5 0.305
	#define cubeUV_m5 3.0
	#define cubeUV_r6 0.21
	#define cubeUV_m6 4.0
	float roughnessToMip( float roughness ) {
		float mip = 0.0;
		if ( roughness >= cubeUV_r1 ) {
			mip = ( cubeUV_r0 - roughness ) * ( cubeUV_m1 - cubeUV_m0 ) / ( cubeUV_r0 - cubeUV_r1 ) + cubeUV_m0;
		} else if ( roughness >= cubeUV_r4 ) {
			mip = ( cubeUV_r1 - roughness ) * ( cubeUV_m4 - cubeUV_m1 ) / ( cubeUV_r1 - cubeUV_r4 ) + cubeUV_m1;
		} else if ( roughness >= cubeUV_r5 ) {
			mip = ( cubeUV_r4 - roughness ) * ( cubeUV_m5 - cubeUV_m4 ) / ( cubeUV_r4 - cubeUV_r5 ) + cubeUV_m4;
		} else if ( roughness >= cubeUV_r6 ) {
			mip = ( cubeUV_r5 - roughness ) * ( cubeUV_m6 - cubeUV_m5 ) / ( cubeUV_r5 - cubeUV_r6 ) + cubeUV_m5;
		} else {
			mip = - 2.0 * log2( 1.16 * roughness );		}
		return mip;
	}
	vec4 textureCubeUV( sampler2D envMap, vec3 sampleDir, float roughness ) {
		float mip = clamp( roughnessToMip( roughness ), cubeUV_m0, CUBEUV_MAX_MIP );
		float mipF = fract( mip );
		float mipInt = floor( mip );
		vec3 color0 = bilinearCubeUV( envMap, sampleDir, mipInt );
		if ( mipF == 0.0 ) {
			return vec4( color0, 1.0 );
		} else {
			vec3 color1 = bilinearCubeUV( envMap, sampleDir, mipInt + 1.0 );
			return vec4( mix( color0, color1, mipF ), 1.0 );
		}
	}
#endif`,N_=`vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT
	vec3 transformedTangent = objectTangent;
#endif
#ifdef USE_BATCHING
	mat3 bm = mat3( batchingMatrix );
	transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
	transformedNormal = bm * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = bm * transformedTangent;
	#endif
#endif
#ifdef USE_INSTANCING
	mat3 im = mat3( instanceMatrix );
	transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	transformedNormal = im * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = im * transformedTangent;
	#endif
#endif
transformedNormal = normalMatrix * transformedNormal;
#ifdef FLIP_SIDED
	transformedNormal = - transformedNormal;
#endif
#ifdef USE_TANGENT
	transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;
	#ifdef FLIP_SIDED
		transformedTangent = - transformedTangent;
	#endif
#endif`,F_=`#ifdef USE_DISPLACEMENTMAP
	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;
#endif`,O_=`#ifdef USE_DISPLACEMENTMAP
	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );
#endif`,B_=`#ifdef USE_EMISSIVEMAP
	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );
	#ifdef DECODE_VIDEO_TEXTURE_EMISSIVE
		emissiveColor = sRGBTransferEOTF( emissiveColor );
	#endif
	totalEmissiveRadiance *= emissiveColor.rgb;
#endif`,z_=`#ifdef USE_EMISSIVEMAP
	uniform sampler2D emissiveMap;
#endif`,k_="gl_FragColor = linearToOutputTexel( gl_FragColor );",H_=`vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}
vec4 sRGBTransferEOTF( in vec4 value ) {
	return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}
vec4 sRGBTransferOETF( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}`,V_=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vec3 cameraToFrag;
		if ( isOrthographic ) {
			cameraToFrag = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToFrag = normalize( vWorldPosition - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vec3 reflectVec = reflect( cameraToFrag, worldNormal );
		#else
			vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );
		#endif
	#else
		vec3 reflectVec = vReflect;
	#endif
	#ifdef ENVMAP_TYPE_CUBE
		vec4 envColor = textureCube( envMap, envMapRotation * vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );
	#else
		vec4 envColor = vec4( 0.0 );
	#endif
	#ifdef ENVMAP_BLENDING_MULTIPLY
		outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_MIX )
		outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_ADD )
		outgoingLight += envColor.xyz * specularStrength * reflectivity;
	#endif
#endif`,G_=`#ifdef USE_ENVMAP
	uniform float envMapIntensity;
	uniform float flipEnvMap;
	uniform mat3 envMapRotation;
	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif
	
#endif`,W_=`#ifdef USE_ENVMAP
	uniform float reflectivity;
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		varying vec3 vWorldPosition;
		uniform float refractionRatio;
	#else
		varying vec3 vReflect;
	#endif
#endif`,X_=`#ifdef USE_ENVMAP
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		
		varying vec3 vWorldPosition;
	#else
		varying vec3 vReflect;
		uniform float refractionRatio;
	#endif
#endif`,q_=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vWorldPosition = worldPosition.xyz;
	#else
		vec3 cameraToVertex;
		if ( isOrthographic ) {
			cameraToVertex = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vReflect = reflect( cameraToVertex, worldNormal );
		#else
			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );
		#endif
	#endif
#endif`,Y_=`#ifdef USE_FOG
	vFogDepth = - mvPosition.z;
#endif`,$_=`#ifdef USE_FOG
	varying float vFogDepth;
#endif`,K_=`#ifdef USE_FOG
	#ifdef FOG_EXP2
		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
	#else
		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
	#endif
	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif`,Z_=`#ifdef USE_FOG
	uniform vec3 fogColor;
	varying float vFogDepth;
	#ifdef FOG_EXP2
		uniform float fogDensity;
	#else
		uniform float fogNear;
		uniform float fogFar;
	#endif
#endif`,j_=`#ifdef USE_GRADIENTMAP
	uniform sampler2D gradientMap;
#endif
vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {
	float dotNL = dot( normal, lightDirection );
	vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );
	#ifdef USE_GRADIENTMAP
		return vec3( texture2D( gradientMap, coord ).r );
	#else
		vec2 fw = fwidth( coord ) * 0.5;
		return mix( vec3( 0.7 ), vec3( 1.0 ), smoothstep( 0.7 - fw.x, 0.7 + fw.x, coord.x ) );
	#endif
}`,J_=`#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif`,Q_=`LambertMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularStrength = specularStrength;`,eg=`varying vec3 vViewPosition;
struct LambertMaterial {
	vec3 diffuseColor;
	float specularStrength;
};
void RE_Direct_Lambert( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Lambert( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Lambert
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert`,tg=`uniform bool receiveShadow;
uniform vec3 ambientLightColor;
#if defined( USE_LIGHT_PROBES )
	uniform vec3 lightProbe[ 9 ];
#endif
vec3 shGetIrradianceAt( in vec3 normal, in vec3 shCoefficients[ 9 ] ) {
	float x = normal.x, y = normal.y, z = normal.z;
	vec3 result = shCoefficients[ 0 ] * 0.886227;
	result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
	result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
	result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;
	result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
	result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
	result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
	result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
	result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );
	return result;
}
vec3 getLightProbeIrradiance( const in vec3 lightProbe[ 9 ], const in vec3 normal ) {
	vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
	vec3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );
	return irradiance;
}
vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {
	vec3 irradiance = ambientLightColor;
	return irradiance;
}
float getDistanceAttenuation( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
	float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
	if ( cutoffDistance > 0.0 ) {
		distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
	}
	return distanceFalloff;
}
float getSpotAttenuation( const in float coneCosine, const in float penumbraCosine, const in float angleCosine ) {
	return smoothstep( coneCosine, penumbraCosine, angleCosine );
}
#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};
	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
	void getDirectionalLightInfo( const in DirectionalLight directionalLight, out IncidentLight light ) {
		light.color = directionalLight.color;
		light.direction = directionalLight.direction;
		light.visible = true;
	}
#endif
#if NUM_POINT_LIGHTS > 0
	struct PointLight {
		vec3 position;
		vec3 color;
		float distance;
		float decay;
	};
	uniform PointLight pointLights[ NUM_POINT_LIGHTS ];
	void getPointLightInfo( const in PointLight pointLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = pointLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float lightDistance = length( lVector );
		light.color = pointLight.color;
		light.color *= getDistanceAttenuation( lightDistance, pointLight.distance, pointLight.decay );
		light.visible = ( light.color != vec3( 0.0 ) );
	}
#endif
#if NUM_SPOT_LIGHTS > 0
	struct SpotLight {
		vec3 position;
		vec3 direction;
		vec3 color;
		float distance;
		float decay;
		float coneCos;
		float penumbraCos;
	};
	uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];
	void getSpotLightInfo( const in SpotLight spotLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = spotLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float angleCos = dot( light.direction, spotLight.direction );
		float spotAttenuation = getSpotAttenuation( spotLight.coneCos, spotLight.penumbraCos, angleCos );
		if ( spotAttenuation > 0.0 ) {
			float lightDistance = length( lVector );
			light.color = spotLight.color * spotAttenuation;
			light.color *= getDistanceAttenuation( lightDistance, spotLight.distance, spotLight.decay );
			light.visible = ( light.color != vec3( 0.0 ) );
		} else {
			light.color = vec3( 0.0 );
			light.visible = false;
		}
	}
#endif
#if NUM_RECT_AREA_LIGHTS > 0
	struct RectAreaLight {
		vec3 color;
		vec3 position;
		vec3 halfWidth;
		vec3 halfHeight;
	};
	uniform sampler2D ltc_1;	uniform sampler2D ltc_2;
	uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];
#endif
#if NUM_HEMI_LIGHTS > 0
	struct HemisphereLight {
		vec3 direction;
		vec3 skyColor;
		vec3 groundColor;
	};
	uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];
	vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in vec3 normal ) {
		float dotNL = dot( normal, hemiLight.direction );
		float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
		vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
		return irradiance;
	}
#endif`,ng=`#ifdef USE_ENVMAP
	vec3 getIBLIrradiance( const in vec3 normal ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * worldNormal, 1.0 );
			return PI * envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 reflectVec = reflect( - viewDir, normal );
			reflectVec = normalize( mix( reflectVec, normal, roughness * roughness) );
			reflectVec = inverseTransformDirection( reflectVec, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, envMapRotation * reflectVec, roughness );
			return envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	#ifdef USE_ANISOTROPY
		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
			#ifdef ENVMAP_TYPE_CUBE_UV
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
				return getIBLRadiance( viewDir, bentNormal, roughness );
			#else
				return vec3( 0.0 );
			#endif
		}
	#endif
#endif`,ig=`ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;`,rg=`varying vec3 vViewPosition;
struct ToonMaterial {
	vec3 diffuseColor;
};
void RE_Direct_Toon( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 irradiance = getGradientIrradiance( geometryNormal, directLight.direction ) * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Toon( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Toon
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon`,sg=`BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;`,ag=`varying vec3 vViewPosition;
struct BlinnPhongMaterial {
	vec3 diffuseColor;
	vec3 specularColor;
	float specularShininess;
	float specularStrength;
};
void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
	reflectedLight.directSpecular += irradiance * BRDF_BlinnPhong( directLight.direction, geometryViewDir, geometryNormal, material.specularColor, material.specularShininess ) * material.specularStrength;
}
void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong`,og=`PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb * ( 1.0 - metalnessFactor );
vec3 dxy = max( abs( dFdx( nonPerturbedNormal ) ), abs( dFdy( nonPerturbedNormal ) ) );
float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );
material.roughness = max( roughnessFactor, 0.0525 );material.roughness += geometryRoughness;
material.roughness = min( material.roughness, 1.0 );
#ifdef IOR
	material.ior = ior;
	#ifdef USE_SPECULAR
		float specularIntensityFactor = specularIntensity;
		vec3 specularColorFactor = specularColor;
		#ifdef USE_SPECULAR_COLORMAP
			specularColorFactor *= texture2D( specularColorMap, vSpecularColorMapUv ).rgb;
		#endif
		#ifdef USE_SPECULAR_INTENSITYMAP
			specularIntensityFactor *= texture2D( specularIntensityMap, vSpecularIntensityMapUv ).a;
		#endif
		material.specularF90 = mix( specularIntensityFactor, 1.0, metalnessFactor );
	#else
		float specularIntensityFactor = 1.0;
		vec3 specularColorFactor = vec3( 1.0 );
		material.specularF90 = 1.0;
	#endif
	material.specularColor = mix( min( pow2( ( material.ior - 1.0 ) / ( material.ior + 1.0 ) ) * specularColorFactor, vec3( 1.0 ) ) * specularIntensityFactor, diffuseColor.rgb, metalnessFactor );
#else
	material.specularColor = mix( vec3( 0.04 ), diffuseColor.rgb, metalnessFactor );
	material.specularF90 = 1.0;
#endif
#ifdef USE_CLEARCOAT
	material.clearcoat = clearcoat;
	material.clearcoatRoughness = clearcoatRoughness;
	material.clearcoatF0 = vec3( 0.04 );
	material.clearcoatF90 = 1.0;
	#ifdef USE_CLEARCOATMAP
		material.clearcoat *= texture2D( clearcoatMap, vClearcoatMapUv ).x;
	#endif
	#ifdef USE_CLEARCOAT_ROUGHNESSMAP
		material.clearcoatRoughness *= texture2D( clearcoatRoughnessMap, vClearcoatRoughnessMapUv ).y;
	#endif
	material.clearcoat = saturate( material.clearcoat );	material.clearcoatRoughness = max( material.clearcoatRoughness, 0.0525 );
	material.clearcoatRoughness += geometryRoughness;
	material.clearcoatRoughness = min( material.clearcoatRoughness, 1.0 );
#endif
#ifdef USE_DISPERSION
	material.dispersion = dispersion;
#endif
#ifdef USE_IRIDESCENCE
	material.iridescence = iridescence;
	material.iridescenceIOR = iridescenceIOR;
	#ifdef USE_IRIDESCENCEMAP
		material.iridescence *= texture2D( iridescenceMap, vIridescenceMapUv ).r;
	#endif
	#ifdef USE_IRIDESCENCE_THICKNESSMAP
		material.iridescenceThickness = (iridescenceThicknessMaximum - iridescenceThicknessMinimum) * texture2D( iridescenceThicknessMap, vIridescenceThicknessMapUv ).g + iridescenceThicknessMinimum;
	#else
		material.iridescenceThickness = iridescenceThicknessMaximum;
	#endif
#endif
#ifdef USE_SHEEN
	material.sheenColor = sheenColor;
	#ifdef USE_SHEEN_COLORMAP
		material.sheenColor *= texture2D( sheenColorMap, vSheenColorMapUv ).rgb;
	#endif
	material.sheenRoughness = clamp( sheenRoughness, 0.07, 1.0 );
	#ifdef USE_SHEEN_ROUGHNESSMAP
		material.sheenRoughness *= texture2D( sheenRoughnessMap, vSheenRoughnessMapUv ).a;
	#endif
#endif
#ifdef USE_ANISOTROPY
	#ifdef USE_ANISOTROPYMAP
		mat2 anisotropyMat = mat2( anisotropyVector.x, anisotropyVector.y, - anisotropyVector.y, anisotropyVector.x );
		vec3 anisotropyPolar = texture2D( anisotropyMap, vAnisotropyMapUv ).rgb;
		vec2 anisotropyV = anisotropyMat * normalize( 2.0 * anisotropyPolar.rg - vec2( 1.0 ) ) * anisotropyPolar.b;
	#else
		vec2 anisotropyV = anisotropyVector;
	#endif
	material.anisotropy = length( anisotropyV );
	if( material.anisotropy == 0.0 ) {
		anisotropyV = vec2( 1.0, 0.0 );
	} else {
		anisotropyV /= material.anisotropy;
		material.anisotropy = saturate( material.anisotropy );
	}
	material.alphaT = mix( pow2( material.roughness ), 1.0, pow2( material.anisotropy ) );
	material.anisotropyT = tbn[ 0 ] * anisotropyV.x + tbn[ 1 ] * anisotropyV.y;
	material.anisotropyB = tbn[ 1 ] * anisotropyV.x - tbn[ 0 ] * anisotropyV.y;
#endif`,lg=`struct PhysicalMaterial {
	vec3 diffuseColor;
	float roughness;
	vec3 specularColor;
	float specularF90;
	float dispersion;
	#ifdef USE_CLEARCOAT
		float clearcoat;
		float clearcoatRoughness;
		vec3 clearcoatF0;
		float clearcoatF90;
	#endif
	#ifdef USE_IRIDESCENCE
		float iridescence;
		float iridescenceIOR;
		float iridescenceThickness;
		vec3 iridescenceFresnel;
		vec3 iridescenceF0;
	#endif
	#ifdef USE_SHEEN
		vec3 sheenColor;
		float sheenRoughness;
	#endif
	#ifdef IOR
		float ior;
	#endif
	#ifdef USE_TRANSMISSION
		float transmission;
		float transmissionAlpha;
		float thickness;
		float attenuationDistance;
		vec3 attenuationColor;
	#endif
	#ifdef USE_ANISOTROPY
		float anisotropy;
		float alphaT;
		vec3 anisotropyT;
		vec3 anisotropyB;
	#endif
};
vec3 clearcoatSpecularDirect = vec3( 0.0 );
vec3 clearcoatSpecularIndirect = vec3( 0.0 );
vec3 sheenSpecularDirect = vec3( 0.0 );
vec3 sheenSpecularIndirect = vec3(0.0 );
vec3 Schlick_to_F0( const in vec3 f, const in float f90, const in float dotVH ) {
    float x = clamp( 1.0 - dotVH, 0.0, 1.0 );
    float x2 = x * x;
    float x5 = clamp( x * x2 * x2, 0.0, 0.9999 );
    return ( f - vec3( f90 ) * x5 ) / ( 1.0 - x5 );
}
float V_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {
	float a2 = pow2( alpha );
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
	return 0.5 / max( gv + gl, EPSILON );
}
float D_GGX( const in float alpha, const in float dotNH ) {
	float a2 = pow2( alpha );
	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
	return RECIPROCAL_PI * a2 / pow2( denom );
}
#ifdef USE_ANISOTROPY
	float V_GGX_SmithCorrelated_Anisotropic( const in float alphaT, const in float alphaB, const in float dotTV, const in float dotBV, const in float dotTL, const in float dotBL, const in float dotNV, const in float dotNL ) {
		float gv = dotNL * length( vec3( alphaT * dotTV, alphaB * dotBV, dotNV ) );
		float gl = dotNV * length( vec3( alphaT * dotTL, alphaB * dotBL, dotNL ) );
		float v = 0.5 / ( gv + gl );
		return saturate(v);
	}
	float D_GGX_Anisotropic( const in float alphaT, const in float alphaB, const in float dotNH, const in float dotTH, const in float dotBH ) {
		float a2 = alphaT * alphaB;
		highp vec3 v = vec3( alphaB * dotTH, alphaT * dotBH, a2 * dotNH );
		highp float v2 = dot( v, v );
		float w2 = a2 / v2;
		return RECIPROCAL_PI * a2 * pow2 ( w2 );
	}
#endif
#ifdef USE_CLEARCOAT
	vec3 BRDF_GGX_Clearcoat( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material) {
		vec3 f0 = material.clearcoatF0;
		float f90 = material.clearcoatF90;
		float roughness = material.clearcoatRoughness;
		float alpha = pow2( roughness );
		vec3 halfDir = normalize( lightDir + viewDir );
		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float dotNH = saturate( dot( normal, halfDir ) );
		float dotVH = saturate( dot( viewDir, halfDir ) );
		vec3 F = F_Schlick( f0, f90, dotVH );
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
		return F * ( V * D );
	}
#endif
vec3 BRDF_GGX( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material ) {
	vec3 f0 = material.specularColor;
	float f90 = material.specularF90;
	float roughness = material.roughness;
	float alpha = pow2( roughness );
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( f0, f90, dotVH );
	#ifdef USE_IRIDESCENCE
		F = mix( F, material.iridescenceFresnel, material.iridescence );
	#endif
	#ifdef USE_ANISOTROPY
		float dotTL = dot( material.anisotropyT, lightDir );
		float dotTV = dot( material.anisotropyT, viewDir );
		float dotTH = dot( material.anisotropyT, halfDir );
		float dotBL = dot( material.anisotropyB, lightDir );
		float dotBV = dot( material.anisotropyB, viewDir );
		float dotBH = dot( material.anisotropyB, halfDir );
		float V = V_GGX_SmithCorrelated_Anisotropic( material.alphaT, alpha, dotTV, dotBV, dotTL, dotBL, dotNV, dotNL );
		float D = D_GGX_Anisotropic( material.alphaT, alpha, dotNH, dotTH, dotBH );
	#else
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
	#endif
	return F * ( V * D );
}
vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {
	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;
	float dotNV = saturate( dot( N, V ) );
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
	uv = uv * LUT_SCALE + LUT_BIAS;
	return uv;
}
float LTC_ClippedSphereFormFactor( const in vec3 f ) {
	float l = length( f );
	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}
vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {
	float x = dot( v1, v2 );
	float y = abs( x );
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;
	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
	return cross( v1, v2 ) * theta_sintheta;
}
vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );
	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 );
	mat3 mat = mInv * transposeMat3( mat3( T1, T2, N ) );
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
	return vec3( result );
}
#if defined( USE_SHEEN )
float D_Charlie( float roughness, float dotNH ) {
	float alpha = pow2( roughness );
	float invAlpha = 1.0 / alpha;
	float cos2h = dotNH * dotNH;
	float sin2h = max( 1.0 - cos2h, 0.0078125 );
	return ( 2.0 + invAlpha ) * pow( sin2h, invAlpha * 0.5 ) / ( 2.0 * PI );
}
float V_Neubelt( float dotNV, float dotNL ) {
	return saturate( 1.0 / ( 4.0 * ( dotNL + dotNV - dotNL * dotNV ) ) );
}
vec3 BRDF_Sheen( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, vec3 sheenColor, const in float sheenRoughness ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float D = D_Charlie( sheenRoughness, dotNH );
	float V = V_Neubelt( dotNV, dotNL );
	return sheenColor * ( D * V );
}
#endif
float IBLSheenBRDF( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	float r2 = roughness * roughness;
	float a = roughness < 0.25 ? -339.2 * r2 + 161.4 * roughness - 25.9 : -8.48 * r2 + 14.3 * roughness - 9.95;
	float b = roughness < 0.25 ? 44.0 * r2 - 23.7 * roughness + 3.26 : 1.97 * r2 - 3.27 * roughness + 0.72;
	float DG = exp( a * dotNV + b ) + ( roughness < 0.25 ? 0.0 : 0.1 * ( roughness - 0.25 ) );
	return saturate( DG * RECIPROCAL_PI );
}
vec2 DFGApprox( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );
	const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );
	vec4 r = roughness * c0 + c1;
	float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
	vec2 fab = vec2( - 1.04, 1.04 ) * a004 + r.zw;
	return fab;
}
vec3 EnvironmentBRDF( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness ) {
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	return specularColor * fab.x + specularF90 * fab.y;
}
#ifdef USE_IRIDESCENCE
void computeMultiscatteringIridescence( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float iridescence, const in vec3 iridescenceF0, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#else
void computeMultiscattering( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#endif
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	#ifdef USE_IRIDESCENCE
		vec3 Fr = mix( specularColor, iridescenceF0, iridescence );
	#else
		vec3 Fr = specularColor;
	#endif
	vec3 FssEss = Fr * fab.x + specularF90 * fab.y;
	float Ess = fab.x + fab.y;
	float Ems = 1.0 - Ess;
	vec3 Favg = Fr + ( 1.0 - Fr ) * 0.047619;	vec3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
	singleScatter += FssEss;
	multiScatter += Fms * Ems;
}
#if NUM_RECT_AREA_LIGHTS > 0
	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
		vec3 normal = geometryNormal;
		vec3 viewDir = geometryViewDir;
		vec3 position = geometryPosition;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.roughness;
		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight;		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;
		vec2 uv = LTC_Uv( normal, viewDir, roughness );
		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );
		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);
		vec3 fresnel = ( material.specularColor * t2.x + ( vec3( 1.0 ) - material.specularColor ) * t2.y );
		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );
		reflectedLight.directDiffuse += lightColor * material.diffuseColor * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );
	}
#endif
void RE_Direct_Physical( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	#ifdef USE_CLEARCOAT
		float dotNLcc = saturate( dot( geometryClearcoatNormal, directLight.direction ) );
		vec3 ccIrradiance = dotNLcc * directLight.color;
		clearcoatSpecularDirect += ccIrradiance * BRDF_GGX_Clearcoat( directLight.direction, geometryViewDir, geometryClearcoatNormal, material );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularDirect += irradiance * BRDF_Sheen( directLight.direction, geometryViewDir, geometryNormal, material.sheenColor, material.sheenRoughness );
	#endif
	reflectedLight.directSpecular += irradiance * BRDF_GGX( directLight.direction, geometryViewDir, geometryNormal, material );
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
	#ifdef USE_CLEARCOAT
		clearcoatSpecularIndirect += clearcoatRadiance * EnvironmentBRDF( geometryClearcoatNormal, geometryViewDir, material.clearcoatF0, material.clearcoatF90, material.clearcoatRoughness );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularIndirect += irradiance * material.sheenColor * IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
	#endif
	vec3 singleScattering = vec3( 0.0 );
	vec3 multiScattering = vec3( 0.0 );
	vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.iridescence, material.iridescenceFresnel, material.roughness, singleScattering, multiScattering );
	#else
		computeMultiscattering( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.roughness, singleScattering, multiScattering );
	#endif
	vec3 totalScattering = singleScattering + multiScattering;
	vec3 diffuse = material.diffuseColor * ( 1.0 - max( max( totalScattering.r, totalScattering.g ), totalScattering.b ) );
	reflectedLight.indirectSpecular += radiance * singleScattering;
	reflectedLight.indirectSpecular += multiScattering * cosineWeightedIrradiance;
	reflectedLight.indirectDiffuse += diffuse * cosineWeightedIrradiance;
}
#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {
	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}`,cg=`
vec3 geometryPosition = - vViewPosition;
vec3 geometryNormal = normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( vViewPosition );
vec3 geometryClearcoatNormal = vec3( 0.0 );
#ifdef USE_CLEARCOAT
	geometryClearcoatNormal = clearcoatNormal;
#endif
#ifdef USE_IRIDESCENCE
	float dotNVi = saturate( dot( normal, geometryViewDir ) );
	if ( material.iridescenceThickness == 0.0 ) {
		material.iridescence = 0.0;
	} else {
		material.iridescence = saturate( material.iridescence );
	}
	if ( material.iridescence > 0.0 ) {
		material.iridescenceFresnel = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		material.iridescenceF0 = Schlick_to_F0( material.iridescenceFresnel, 1.0, dotNVi );
	}
#endif
IncidentLight directLight;
#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )
	PointLight pointLight;
	#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {
		pointLight = pointLights[ i ];
		getPointLightInfo( pointLight, geometryPosition, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_POINT_LIGHT_SHADOWS )
		pointLightShadow = pointLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getPointShadow( pointShadowMap[ i ], pointLightShadow.shadowMapSize, pointLightShadow.shadowIntensity, pointLightShadow.shadowBias, pointLightShadow.shadowRadius, vPointShadowCoord[ i ], pointLightShadow.shadowCameraNear, pointLightShadow.shadowCameraFar ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )
	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;
	#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {
		spotLight = spotLights[ i ];
		getSpotLightInfo( spotLight, geometryPosition, directLight );
		#if ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#define SPOT_LIGHT_MAP_INDEX UNROLLED_LOOP_INDEX
		#elif ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		#define SPOT_LIGHT_MAP_INDEX NUM_SPOT_LIGHT_MAPS
		#else
		#define SPOT_LIGHT_MAP_INDEX ( UNROLLED_LOOP_INDEX - NUM_SPOT_LIGHT_SHADOWS + NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#endif
		#if ( SPOT_LIGHT_MAP_INDEX < NUM_SPOT_LIGHT_MAPS )
			spotLightCoord = vSpotLightCoord[ i ].xyz / vSpotLightCoord[ i ].w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3( 1.0 ) ) );
			spotColor = texture2D( spotLightMap[ SPOT_LIGHT_MAP_INDEX ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		#endif
		#undef SPOT_LIGHT_MAP_INDEX
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		spotLightShadow = spotLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( spotShadowMap[ i ], spotLightShadow.shadowMapSize, spotLightShadow.shadowIntensity, spotLightShadow.shadowBias, spotLightShadow.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )
	DirectionalLight directionalLight;
	#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {
		directionalLight = directionalLights[ i ];
		getDirectionalLightInfo( directionalLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_DIR_LIGHT_SHADOWS )
		directionalLightShadow = directionalLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( directionalShadowMap[ i ], directionalLightShadow.shadowMapSize, directionalLightShadow.shadowIntensity, directionalLightShadow.shadowBias, directionalLightShadow.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )
	RectAreaLight rectAreaLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {
		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if defined( RE_IndirectDiffuse )
	vec3 iblIrradiance = vec3( 0.0 );
	vec3 irradiance = getAmbientLightIrradiance( ambientLightColor );
	#if defined( USE_LIGHT_PROBES )
		irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );
	#endif
	#if ( NUM_HEMI_LIGHTS > 0 )
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {
			irradiance += getHemisphereLightIrradiance( hemisphereLights[ i ], geometryNormal );
		}
		#pragma unroll_loop_end
	#endif
#endif
#if defined( RE_IndirectSpecular )
	vec3 radiance = vec3( 0.0 );
	vec3 clearcoatRadiance = vec3( 0.0 );
#endif`,ug=`#if defined( RE_IndirectDiffuse )
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
		irradiance += lightMapIrradiance;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD ) && defined( ENVMAP_TYPE_CUBE_UV )
		iblIrradiance += getIBLIrradiance( geometryNormal );
	#endif
#endif
#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )
	#ifdef USE_ANISOTROPY
		radiance += getIBLAnisotropyRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
	#else
		radiance += getIBLRadiance( geometryViewDir, geometryNormal, material.roughness );
	#endif
	#ifdef USE_CLEARCOAT
		clearcoatRadiance += getIBLRadiance( geometryViewDir, geometryClearcoatNormal, material.clearcoatRoughness );
	#endif
#endif`,fg=`#if defined( RE_IndirectDiffuse )
	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif
#if defined( RE_IndirectSpecular )
	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif`,hg=`#if defined( USE_LOGDEPTHBUF )
	gl_FragDepth = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif`,dg=`#if defined( USE_LOGDEPTHBUF )
	uniform float logDepthBufFC;
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,pg=`#ifdef USE_LOGDEPTHBUF
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,mg=`#ifdef USE_LOGDEPTHBUF
	vFragDepth = 1.0 + gl_Position.w;
	vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
#endif`,_g=`#ifdef USE_MAP
	vec4 sampledDiffuseColor = texture2D( map, vMapUv );
	#ifdef DECODE_VIDEO_TEXTURE
		sampledDiffuseColor = sRGBTransferEOTF( sampledDiffuseColor );
	#endif
	diffuseColor *= sampledDiffuseColor;
#endif`,gg=`#ifdef USE_MAP
	uniform sampler2D map;
#endif`,vg=`#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
	#if defined( USE_POINTS_UV )
		vec2 uv = vUv;
	#else
		vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;
	#endif
#endif
#ifdef USE_MAP
	diffuseColor *= texture2D( map, uv );
#endif
#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, uv ).g;
#endif`,xg=`#if defined( USE_POINTS_UV )
	varying vec2 vUv;
#else
	#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
		uniform mat3 uvTransform;
	#endif
#endif
#ifdef USE_MAP
	uniform sampler2D map;
#endif
#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,Mg=`float metalnessFactor = metalness;
#ifdef USE_METALNESSMAP
	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );
	metalnessFactor *= texelMetalness.b;
#endif`,Sg=`#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif`,yg=`#ifdef USE_INSTANCING_MORPH
	float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	float morphTargetBaseInfluence = texelFetch( morphTexture, ivec2( 0, gl_InstanceID ), 0 ).r;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		morphTargetInfluences[i] =  texelFetch( morphTexture, ivec2( i + 1, gl_InstanceID ), 0 ).r;
	}
#endif`,Eg=`#if defined( USE_MORPHCOLORS )
	vColor *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		#if defined( USE_COLOR_ALPHA )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
		#elif defined( USE_COLOR )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
		#endif
	}
#endif`,Tg=`#ifdef USE_MORPHNORMALS
	objectNormal *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,bg=`#ifdef USE_MORPHTARGETS
	#ifndef USE_INSTANCING_MORPH
		uniform float morphTargetBaseInfluence;
		uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	#endif
	uniform sampler2DArray morphTargetsTexture;
	uniform ivec2 morphTargetsTextureSize;
	vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {
		int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
		int y = texelIndex / morphTargetsTextureSize.x;
		int x = texelIndex - y * morphTargetsTextureSize.x;
		ivec3 morphUV = ivec3( x, y, morphTargetIndex );
		return texelFetch( morphTargetsTexture, morphUV, 0 );
	}
#endif`,Ag=`#ifdef USE_MORPHTARGETS
	transformed *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,wg=`float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
#ifdef FLAT_SHADED
	vec3 fdx = dFdx( vViewPosition );
	vec3 fdy = dFdy( vViewPosition );
	vec3 normal = normalize( cross( fdx, fdy ) );
#else
	vec3 normal = normalize( vNormal );
	#ifdef DOUBLE_SIDED
		normal *= faceDirection;
	#endif
#endif
#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )
	#ifdef USE_TANGENT
		mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn = getTangentFrame( - vViewPosition, normal,
		#if defined( USE_NORMALMAP )
			vNormalMapUv
		#elif defined( USE_CLEARCOAT_NORMALMAP )
			vClearcoatNormalMapUv
		#else
			vUv
		#endif
		);
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn[0] *= faceDirection;
		tbn[1] *= faceDirection;
	#endif
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	#ifdef USE_TANGENT
		mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn2[0] *= faceDirection;
		tbn2[1] *= faceDirection;
	#endif
#endif
vec3 nonPerturbedNormal = normal;`,Rg=`#ifdef USE_NORMALMAP_OBJECTSPACE
	normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#ifdef FLIP_SIDED
		normal = - normal;
	#endif
	#ifdef DOUBLE_SIDED
		normal = normal * faceDirection;
	#endif
	normal = normalize( normalMatrix * normal );
#elif defined( USE_NORMALMAP_TANGENTSPACE )
	vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	mapN.xy *= normalScale;
	normal = normalize( tbn * mapN );
#elif defined( USE_BUMPMAP )
	normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );
#endif`,Cg=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,Pg=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,Dg=`#ifndef FLAT_SHADED
	vNormal = normalize( transformedNormal );
	#ifdef USE_TANGENT
		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );
	#endif
#endif`,Lg=`#ifdef USE_NORMALMAP
	uniform sampler2D normalMap;
	uniform vec2 normalScale;
#endif
#ifdef USE_NORMALMAP_OBJECTSPACE
	uniform mat3 normalMatrix;
#endif
#if ! defined ( USE_TANGENT ) && ( defined ( USE_NORMALMAP_TANGENTSPACE ) || defined ( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY ) )
	mat3 getTangentFrame( vec3 eye_pos, vec3 surf_norm, vec2 uv ) {
		vec3 q0 = dFdx( eye_pos.xyz );
		vec3 q1 = dFdy( eye_pos.xyz );
		vec2 st0 = dFdx( uv.st );
		vec2 st1 = dFdy( uv.st );
		vec3 N = surf_norm;
		vec3 q1perp = cross( q1, N );
		vec3 q0perp = cross( N, q0 );
		vec3 T = q1perp * st0.x + q0perp * st1.x;
		vec3 B = q1perp * st0.y + q0perp * st1.y;
		float det = max( dot( T, T ), dot( B, B ) );
		float scale = ( det == 0.0 ) ? 0.0 : inversesqrt( det );
		return mat3( T * scale, B * scale, N );
	}
#endif`,Ig=`#ifdef USE_CLEARCOAT
	vec3 clearcoatNormal = nonPerturbedNormal;
#endif`,Ug=`#ifdef USE_CLEARCOAT_NORMALMAP
	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;
	clearcoatNormal = normalize( tbn2 * clearcoatMapN );
#endif`,Ng=`#ifdef USE_CLEARCOATMAP
	uniform sampler2D clearcoatMap;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform sampler2D clearcoatRoughnessMap;
#endif`,Fg=`#ifdef USE_IRIDESCENCEMAP
	uniform sampler2D iridescenceMap;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform sampler2D iridescenceThicknessMap;
#endif`,Og=`#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );`,Bg=`vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}
vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}
const float PackUpscale = 256. / 255.;const float UnpackDownscale = 255. / 256.;const float ShiftRight8 = 1. / 256.;
const float Inv255 = 1. / 255.;
const vec4 PackFactors = vec4( 1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0 );
const vec2 UnpackFactors2 = vec2( UnpackDownscale, 1.0 / PackFactors.g );
const vec3 UnpackFactors3 = vec3( UnpackDownscale / PackFactors.rg, 1.0 / PackFactors.b );
const vec4 UnpackFactors4 = vec4( UnpackDownscale / PackFactors.rgb, 1.0 / PackFactors.a );
vec4 packDepthToRGBA( const in float v ) {
	if( v <= 0.0 )
		return vec4( 0., 0., 0., 0. );
	if( v >= 1.0 )
		return vec4( 1., 1., 1., 1. );
	float vuf;
	float af = modf( v * PackFactors.a, vuf );
	float bf = modf( vuf * ShiftRight8, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec4( vuf * Inv255, gf * PackUpscale, bf * PackUpscale, af );
}
vec3 packDepthToRGB( const in float v ) {
	if( v <= 0.0 )
		return vec3( 0., 0., 0. );
	if( v >= 1.0 )
		return vec3( 1., 1., 1. );
	float vuf;
	float bf = modf( v * PackFactors.b, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec3( vuf * Inv255, gf * PackUpscale, bf );
}
vec2 packDepthToRG( const in float v ) {
	if( v <= 0.0 )
		return vec2( 0., 0. );
	if( v >= 1.0 )
		return vec2( 1., 1. );
	float vuf;
	float gf = modf( v * 256., vuf );
	return vec2( vuf * Inv255, gf );
}
float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors4 );
}
float unpackRGBToDepth( const in vec3 v ) {
	return dot( v, UnpackFactors3 );
}
float unpackRGToDepth( const in vec2 v ) {
	return v.r * UnpackFactors2.r + v.g * UnpackFactors2.g;
}
vec4 pack2HalfToRGBA( const in vec2 v ) {
	vec4 r = vec4( v.x, fract( v.x * 255.0 ), v.y, fract( v.y * 255.0 ) );
	return vec4( r.x - r.y / 255.0, r.y, r.z - r.w / 255.0, r.w );
}
vec2 unpackRGBATo2Half( const in vec4 v ) {
	return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}
float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
	return ( viewZ + near ) / ( near - far );
}
float orthographicDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return depth * ( near - far ) - near;
}
float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
	return ( ( near + viewZ ) * far ) / ( ( far - near ) * viewZ );
}
float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return ( near * far ) / ( ( far - near ) * depth - far );
}`,zg=`#ifdef PREMULTIPLIED_ALPHA
	gl_FragColor.rgb *= gl_FragColor.a;
#endif`,kg=`vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
	mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
	mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;`,Hg=`#ifdef DITHERING
	gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif`,Vg=`#ifdef DITHERING
	vec3 dithering( vec3 color ) {
		float grid_position = rand( gl_FragCoord.xy );
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
		return color + dither_shift_RGB;
	}
#endif`,Gg=`float roughnessFactor = roughness;
#ifdef USE_ROUGHNESSMAP
	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );
	roughnessFactor *= texelRoughness.g;
#endif`,Wg=`#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif`,Xg=`#if NUM_SPOT_LIGHT_COORDS > 0
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#if NUM_SPOT_LIGHT_MAPS > 0
	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform sampler2D pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
	float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {
		return step( compare, unpackRGBAToDepth( texture2D( depths, uv ) ) );
	}
	vec2 texture2DDistribution( sampler2D shadow, vec2 uv ) {
		return unpackRGBATo2Half( texture2D( shadow, uv ) );
	}
	float VSMShadow (sampler2D shadow, vec2 uv, float compare ){
		float occlusion = 1.0;
		vec2 distribution = texture2DDistribution( shadow, uv );
		float hard_shadow = step( compare , distribution.x );
		if (hard_shadow != 1.0 ) {
			float distance = compare - distribution.x ;
			float variance = max( 0.00000, distribution.y * distribution.y );
			float softness_probability = variance / (variance + distance * distance );			softness_probability = clamp( ( softness_probability - 0.3 ) / ( 0.95 - 0.3 ), 0.0, 1.0 );			occlusion = clamp( max( hard_shadow, softness_probability ), 0.0, 1.0 );
		}
		return occlusion;
	}
	float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
		float shadow = 1.0;
		shadowCoord.xyz /= shadowCoord.w;
		shadowCoord.z += shadowBias;
		bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
		bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
		if ( frustumTest ) {
		#if defined( SHADOWMAP_TYPE_PCF )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx0 = - texelSize.x * shadowRadius;
			float dy0 = - texelSize.y * shadowRadius;
			float dx1 = + texelSize.x * shadowRadius;
			float dy1 = + texelSize.y * shadowRadius;
			float dx2 = dx0 / 2.0;
			float dy2 = dy0 / 2.0;
			float dx3 = dx1 / 2.0;
			float dy3 = dy1 / 2.0;
			shadow = (
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
			) * ( 1.0 / 17.0 );
		#elif defined( SHADOWMAP_TYPE_PCF_SOFT )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx = texelSize.x;
			float dy = texelSize.y;
			vec2 uv = shadowCoord.xy;
			vec2 f = fract( uv * shadowMapSize + 0.5 );
			uv -= f * texelSize;
			shadow = (
				texture2DCompare( shadowMap, uv, shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( dx, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( 0.0, dy ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + texelSize, shadowCoord.z ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, 0.0 ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 0.0 ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, dy ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( 0.0, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 0.0, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( texture2DCompare( shadowMap, uv + vec2( dx, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( dx, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( mix( texture2DCompare( shadowMap, uv + vec2( -dx, -dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, -dy ), shadowCoord.z ),
						  f.x ),
					 mix( texture2DCompare( shadowMap, uv + vec2( -dx, 2.0 * dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 2.0 * dy ), shadowCoord.z ),
						  f.x ),
					 f.y )
			) * ( 1.0 / 9.0 );
		#elif defined( SHADOWMAP_TYPE_VSM )
			shadow = VSMShadow( shadowMap, shadowCoord.xy, shadowCoord.z );
		#else
			shadow = texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z );
		#endif
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
	vec2 cubeToUV( vec3 v, float texelSizeY ) {
		vec3 absV = abs( v );
		float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
		absV *= scaleToCube;
		v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );
		vec2 planar = v.xy;
		float almostATexel = 1.5 * texelSizeY;
		float almostOne = 1.0 - almostATexel;
		if ( absV.z >= almostOne ) {
			if ( v.z > 0.0 )
				planar.x = 4.0 - v.x;
		} else if ( absV.x >= almostOne ) {
			float signX = sign( v.x );
			planar.x = v.z * signX + 2.0 * signX;
		} else if ( absV.y >= almostOne ) {
			float signY = sign( v.y );
			planar.x = v.x + 2.0 * signY + 2.0;
			planar.y = v.z * signY - 2.0;
		}
		return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );
	}
	float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		float shadow = 1.0;
		vec3 lightToPosition = shadowCoord.xyz;
		
		float lightToPositionLength = length( lightToPosition );
		if ( lightToPositionLength - shadowCameraFar <= 0.0 && lightToPositionLength - shadowCameraNear >= 0.0 ) {
			float dp = ( lightToPositionLength - shadowCameraNear ) / ( shadowCameraFar - shadowCameraNear );			dp += shadowBias;
			vec3 bd3D = normalize( lightToPosition );
			vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );
			#if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT ) || defined( SHADOWMAP_TYPE_VSM )
				vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;
				shadow = (
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
					texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
				) * ( 1.0 / 9.0 );
			#else
				shadow = texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );
			#endif
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
#endif`,qg=`#if NUM_SPOT_LIGHT_COORDS > 0
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
#endif`,Yg=`#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )
	vec3 shadowWorldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
	vec4 shadowWorldPosition;
#endif
#if defined( USE_SHADOWMAP )
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * directionalLightShadows[ i ].shadowNormalBias, 0 );
			vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * pointLightShadows[ i ].shadowNormalBias, 0 );
			vPointShadowCoord[ i ] = pointShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_COORDS; i ++ ) {
		shadowWorldPosition = worldPosition;
		#if ( defined( USE_SHADOWMAP ) && UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
			shadowWorldPosition.xyz += shadowWorldNormal * spotLightShadows[ i ].shadowNormalBias;
		#endif
		vSpotLightCoord[ i ] = spotLightMatrix[ i ] * shadowWorldPosition;
	}
	#pragma unroll_loop_end
#endif`,$g=`float getShadowMask() {
	float shadow = 1.0;
	#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
		directionalLight = directionalLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowIntensity, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_SHADOWS; i ++ ) {
		spotLight = spotLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowIntensity, spotLight.shadowBias, spotLight.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
		pointLight = pointLightShadows[ i ];
		shadow *= receiveShadow ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowIntensity, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#endif
	return shadow;
}`,Kg=`#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif`,Zg=`#ifdef USE_SKINNING
	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;
	uniform highp sampler2D boneTexture;
	mat4 getBoneMatrix( const in float i ) {
		int size = textureSize( boneTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,jg=`#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif`,Jg=`#ifdef USE_SKINNING
	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;
	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
	#ifdef USE_TANGENT
		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
	#endif
#endif`,Qg=`float specularStrength;
#ifdef USE_SPECULARMAP
	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;
#else
	specularStrength = 1.0;
#endif`,e0=`#ifdef USE_SPECULARMAP
	uniform sampler2D specularMap;
#endif`,t0=`#if defined( TONE_MAPPING )
	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif`,n0=`#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
uniform float toneMappingExposure;
vec3 LinearToneMapping( vec3 color ) {
	return saturate( toneMappingExposure * color );
}
vec3 ReinhardToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );
}
vec3 CineonToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 RRTAndODTFit( vec3 v ) {
	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
	return a / b;
}
vec3 ACESFilmicToneMapping( vec3 color ) {
	const mat3 ACESInputMat = mat3(
		vec3( 0.59719, 0.07600, 0.02840 ),		vec3( 0.35458, 0.90834, 0.13383 ),
		vec3( 0.04823, 0.01566, 0.83777 )
	);
	const mat3 ACESOutputMat = mat3(
		vec3(  1.60475, -0.10208, -0.00327 ),		vec3( -0.53108,  1.10813, -0.07276 ),
		vec3( -0.07367, -0.00605,  1.07602 )
	);
	color *= toneMappingExposure / 0.6;
	color = ACESInputMat * color;
	color = RRTAndODTFit( color );
	color = ACESOutputMat * color;
	return saturate( color );
}
const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
	vec3( 1.6605, - 0.1246, - 0.0182 ),
	vec3( - 0.5876, 1.1329, - 0.1006 ),
	vec3( - 0.0728, - 0.0083, 1.1187 )
);
const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
	vec3( 0.6274, 0.0691, 0.0164 ),
	vec3( 0.3293, 0.9195, 0.0880 ),
	vec3( 0.0433, 0.0113, 0.8956 )
);
vec3 agxDefaultContrastApprox( vec3 x ) {
	vec3 x2 = x * x;
	vec3 x4 = x2 * x2;
	return + 15.5 * x4 * x2
		- 40.14 * x4 * x
		+ 31.96 * x4
		- 6.868 * x2 * x
		+ 0.4298 * x2
		+ 0.1191 * x
		- 0.00232;
}
vec3 AgXToneMapping( vec3 color ) {
	const mat3 AgXInsetMatrix = mat3(
		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
	);
	const mat3 AgXOutsetMatrix = mat3(
		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
	);
	const float AgxMinEv = - 12.47393;	const float AgxMaxEv = 4.026069;
	color *= toneMappingExposure;
	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
	color = AgXInsetMatrix * color;
	color = max( color, 1e-10 );	color = log2( color );
	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );
	color = clamp( color, 0.0, 1.0 );
	color = agxDefaultContrastApprox( color );
	color = AgXOutsetMatrix * color;
	color = pow( max( vec3( 0.0 ), color ), vec3( 2.2 ) );
	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
	color = clamp( color, 0.0, 1.0 );
	return color;
}
vec3 NeutralToneMapping( vec3 color ) {
	const float StartCompression = 0.8 - 0.04;
	const float Desaturation = 0.15;
	color *= toneMappingExposure;
	float x = min( color.r, min( color.g, color.b ) );
	float offset = x < 0.08 ? x - 6.25 * x * x : 0.04;
	color -= offset;
	float peak = max( color.r, max( color.g, color.b ) );
	if ( peak < StartCompression ) return color;
	float d = 1. - StartCompression;
	float newPeak = 1. - d * d / ( peak + d - StartCompression );
	color *= newPeak / peak;
	float g = 1. - 1. / ( Desaturation * ( peak - newPeak ) + 1. );
	return mix( color, vec3( newPeak ), g );
}
vec3 CustomToneMapping( vec3 color ) { return color; }`,i0=`#ifdef USE_TRANSMISSION
	material.transmission = transmission;
	material.transmissionAlpha = 1.0;
	material.thickness = thickness;
	material.attenuationDistance = attenuationDistance;
	material.attenuationColor = attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		material.transmission *= texture2D( transmissionMap, vTransmissionMapUv ).r;
	#endif
	#ifdef USE_THICKNESSMAP
		material.thickness *= texture2D( thicknessMap, vThicknessMapUv ).g;
	#endif
	vec3 pos = vWorldPosition;
	vec3 v = normalize( cameraPosition - pos );
	vec3 n = inverseTransformDirection( normal, viewMatrix );
	vec4 transmitted = getIBLVolumeRefraction(
		n, v, material.roughness, material.diffuseColor, material.specularColor, material.specularF90,
		pos, modelMatrix, viewMatrix, projectionMatrix, material.dispersion, material.ior, material.thickness,
		material.attenuationColor, material.attenuationDistance );
	material.transmissionAlpha = mix( material.transmissionAlpha, transmitted.a, material.transmission );
	totalDiffuse = mix( totalDiffuse, transmitted.rgb, material.transmission );
#endif`,r0=`#ifdef USE_TRANSMISSION
	uniform float transmission;
	uniform float thickness;
	uniform float attenuationDistance;
	uniform vec3 attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		uniform sampler2D transmissionMap;
	#endif
	#ifdef USE_THICKNESSMAP
		uniform sampler2D thicknessMap;
	#endif
	uniform vec2 transmissionSamplerSize;
	uniform sampler2D transmissionSamplerMap;
	uniform mat4 modelMatrix;
	uniform mat4 projectionMatrix;
	varying vec3 vWorldPosition;
	float w0( float a ) {
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - a + 3.0 ) - 3.0 ) + 1.0 );
	}
	float w1( float a ) {
		return ( 1.0 / 6.0 ) * ( a *  a * ( 3.0 * a - 6.0 ) + 4.0 );
	}
	float w2( float a ){
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - 3.0 * a + 3.0 ) + 3.0 ) + 1.0 );
	}
	float w3( float a ) {
		return ( 1.0 / 6.0 ) * ( a * a * a );
	}
	float g0( float a ) {
		return w0( a ) + w1( a );
	}
	float g1( float a ) {
		return w2( a ) + w3( a );
	}
	float h0( float a ) {
		return - 1.0 + w1( a ) / ( w0( a ) + w1( a ) );
	}
	float h1( float a ) {
		return 1.0 + w3( a ) / ( w2( a ) + w3( a ) );
	}
	vec4 bicubic( sampler2D tex, vec2 uv, vec4 texelSize, float lod ) {
		uv = uv * texelSize.zw + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		float g0x = g0( fuv.x );
		float g1x = g1( fuv.x );
		float h0x = h0( fuv.x );
		float h1x = h1( fuv.x );
		float h0y = h0( fuv.y );
		float h1y = h1( fuv.y );
		vec2 p0 = ( vec2( iuv.x + h0x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p1 = ( vec2( iuv.x + h1x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p2 = ( vec2( iuv.x + h0x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		vec2 p3 = ( vec2( iuv.x + h1x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		return g0( fuv.y ) * ( g0x * textureLod( tex, p0, lod ) + g1x * textureLod( tex, p1, lod ) ) +
			g1( fuv.y ) * ( g0x * textureLod( tex, p2, lod ) + g1x * textureLod( tex, p3, lod ) );
	}
	vec4 textureBicubic( sampler2D sampler, vec2 uv, float lod ) {
		vec2 fLodSize = vec2( textureSize( sampler, int( lod ) ) );
		vec2 cLodSize = vec2( textureSize( sampler, int( lod + 1.0 ) ) );
		vec2 fLodSizeInv = 1.0 / fLodSize;
		vec2 cLodSizeInv = 1.0 / cLodSize;
		vec4 fSample = bicubic( sampler, uv, vec4( fLodSizeInv, fLodSize ), floor( lod ) );
		vec4 cSample = bicubic( sampler, uv, vec4( cLodSizeInv, cLodSize ), ceil( lod ) );
		return mix( fSample, cSample, fract( lod ) );
	}
	vec3 getVolumeTransmissionRay( const in vec3 n, const in vec3 v, const in float thickness, const in float ior, const in mat4 modelMatrix ) {
		vec3 refractionVector = refract( - v, normalize( n ), 1.0 / ior );
		vec3 modelScale;
		modelScale.x = length( vec3( modelMatrix[ 0 ].xyz ) );
		modelScale.y = length( vec3( modelMatrix[ 1 ].xyz ) );
		modelScale.z = length( vec3( modelMatrix[ 2 ].xyz ) );
		return normalize( refractionVector ) * thickness * modelScale;
	}
	float applyIorToRoughness( const in float roughness, const in float ior ) {
		return roughness * clamp( ior * 2.0 - 2.0, 0.0, 1.0 );
	}
	vec4 getTransmissionSample( const in vec2 fragCoord, const in float roughness, const in float ior ) {
		float lod = log2( transmissionSamplerSize.x ) * applyIorToRoughness( roughness, ior );
		return textureBicubic( transmissionSamplerMap, fragCoord.xy, lod );
	}
	vec3 volumeAttenuation( const in float transmissionDistance, const in vec3 attenuationColor, const in float attenuationDistance ) {
		if ( isinf( attenuationDistance ) ) {
			return vec3( 1.0 );
		} else {
			vec3 attenuationCoefficient = -log( attenuationColor ) / attenuationDistance;
			vec3 transmittance = exp( - attenuationCoefficient * transmissionDistance );			return transmittance;
		}
	}
	vec4 getIBLVolumeRefraction( const in vec3 n, const in vec3 v, const in float roughness, const in vec3 diffuseColor,
		const in vec3 specularColor, const in float specularF90, const in vec3 position, const in mat4 modelMatrix,
		const in mat4 viewMatrix, const in mat4 projMatrix, const in float dispersion, const in float ior, const in float thickness,
		const in vec3 attenuationColor, const in float attenuationDistance ) {
		vec4 transmittedLight;
		vec3 transmittance;
		#ifdef USE_DISPERSION
			float halfSpread = ( ior - 1.0 ) * 0.025 * dispersion;
			vec3 iors = vec3( ior - halfSpread, ior, ior + halfSpread );
			for ( int i = 0; i < 3; i ++ ) {
				vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, iors[ i ], modelMatrix );
				vec3 refractedRayExit = position + transmissionRay;
		
				vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
				vec2 refractionCoords = ndcPos.xy / ndcPos.w;
				refractionCoords += 1.0;
				refractionCoords /= 2.0;
		
				vec4 transmissionSample = getTransmissionSample( refractionCoords, roughness, iors[ i ] );
				transmittedLight[ i ] = transmissionSample[ i ];
				transmittedLight.a += transmissionSample.a;
				transmittance[ i ] = diffuseColor[ i ] * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance )[ i ];
			}
			transmittedLight.a /= 3.0;
		
		#else
		
			vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, ior, modelMatrix );
			vec3 refractedRayExit = position + transmissionRay;
			vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
			vec2 refractionCoords = ndcPos.xy / ndcPos.w;
			refractionCoords += 1.0;
			refractionCoords /= 2.0;
			transmittedLight = getTransmissionSample( refractionCoords, roughness, ior );
			transmittance = diffuseColor * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance );
		
		#endif
		vec3 attenuatedColor = transmittance * transmittedLight.rgb;
		vec3 F = EnvironmentBRDF( n, v, specularColor, specularF90, roughness );
		float transmittanceFactor = ( transmittance.r + transmittance.g + transmittance.b ) / 3.0;
		return vec4( ( 1.0 - F ) * attenuatedColor, 1.0 - ( 1.0 - transmittedLight.a ) * transmittanceFactor );
	}
#endif`,s0=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_SPECULARMAP
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,a0=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	uniform mat3 mapTransform;
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	uniform mat3 alphaMapTransform;
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	uniform mat3 lightMapTransform;
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	uniform mat3 aoMapTransform;
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	uniform mat3 bumpMapTransform;
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	uniform mat3 normalMapTransform;
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_DISPLACEMENTMAP
	uniform mat3 displacementMapTransform;
	varying vec2 vDisplacementMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	uniform mat3 emissiveMapTransform;
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	uniform mat3 metalnessMapTransform;
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	uniform mat3 roughnessMapTransform;
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	uniform mat3 anisotropyMapTransform;
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	uniform mat3 clearcoatMapTransform;
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform mat3 clearcoatNormalMapTransform;
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform mat3 clearcoatRoughnessMapTransform;
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	uniform mat3 sheenColorMapTransform;
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	uniform mat3 sheenRoughnessMapTransform;
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	uniform mat3 iridescenceMapTransform;
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform mat3 iridescenceThicknessMapTransform;
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SPECULARMAP
	uniform mat3 specularMapTransform;
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	uniform mat3 specularColorMapTransform;
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	uniform mat3 specularIntensityMapTransform;
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,o0=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	vUv = vec3( uv, 1 ).xy;
#endif
#ifdef USE_MAP
	vMapUv = ( mapTransform * vec3( MAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ALPHAMAP
	vAlphaMapUv = ( alphaMapTransform * vec3( ALPHAMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_LIGHTMAP
	vLightMapUv = ( lightMapTransform * vec3( LIGHTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_AOMAP
	vAoMapUv = ( aoMapTransform * vec3( AOMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_BUMPMAP
	vBumpMapUv = ( bumpMapTransform * vec3( BUMPMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_NORMALMAP
	vNormalMapUv = ( normalMapTransform * vec3( NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_DISPLACEMENTMAP
	vDisplacementMapUv = ( displacementMapTransform * vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_EMISSIVEMAP
	vEmissiveMapUv = ( emissiveMapTransform * vec3( EMISSIVEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_METALNESSMAP
	vMetalnessMapUv = ( metalnessMapTransform * vec3( METALNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ROUGHNESSMAP
	vRoughnessMapUv = ( roughnessMapTransform * vec3( ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ANISOTROPYMAP
	vAnisotropyMapUv = ( anisotropyMapTransform * vec3( ANISOTROPYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOATMAP
	vClearcoatMapUv = ( clearcoatMapTransform * vec3( CLEARCOATMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	vClearcoatNormalMapUv = ( clearcoatNormalMapTransform * vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	vClearcoatRoughnessMapUv = ( clearcoatRoughnessMapTransform * vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCEMAP
	vIridescenceMapUv = ( iridescenceMapTransform * vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	vIridescenceThicknessMapUv = ( iridescenceThicknessMapTransform * vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_COLORMAP
	vSheenColorMapUv = ( sheenColorMapTransform * vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	vSheenRoughnessMapUv = ( sheenRoughnessMapTransform * vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULARMAP
	vSpecularMapUv = ( specularMapTransform * vec3( SPECULARMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_COLORMAP
	vSpecularColorMapUv = ( specularColorMapTransform * vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	vSpecularIntensityMapUv = ( specularIntensityMapTransform * vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_TRANSMISSIONMAP
	vTransmissionMapUv = ( transmissionMapTransform * vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_THICKNESSMAP
	vThicknessMapUv = ( thicknessMapTransform * vec3( THICKNESSMAP_UV, 1 ) ).xy;
#endif`,l0=`#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0
	vec4 worldPosition = vec4( transformed, 1.0 );
	#ifdef USE_BATCHING
		worldPosition = batchingMatrix * worldPosition;
	#endif
	#ifdef USE_INSTANCING
		worldPosition = instanceMatrix * worldPosition;
	#endif
	worldPosition = modelMatrix * worldPosition;
#endif`;const c0=`varying vec2 vUv;
uniform mat3 uvTransform;
void main() {
	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	gl_Position = vec4( position.xy, 1.0, 1.0 );
}`,u0=`uniform sampler2D t2D;
uniform float backgroundIntensity;
varying vec2 vUv;
void main() {
	vec4 texColor = texture2D( t2D, vUv );
	#ifdef DECODE_VIDEO_TEXTURE
		texColor = vec4( mix( pow( texColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), texColor.rgb * 0.0773993808, vec3( lessThanEqual( texColor.rgb, vec3( 0.04045 ) ) ) ), texColor.w );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,f0=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,h0=`#ifdef ENVMAP_TYPE_CUBE
	uniform samplerCube envMap;
#elif defined( ENVMAP_TYPE_CUBE_UV )
	uniform sampler2D envMap;
#endif
uniform float flipEnvMap;
uniform float backgroundBlurriness;
uniform float backgroundIntensity;
uniform mat3 backgroundRotation;
varying vec3 vWorldDirection;
#include <cube_uv_reflection_fragment>
void main() {
	#ifdef ENVMAP_TYPE_CUBE
		vec4 texColor = textureCube( envMap, backgroundRotation * vec3( flipEnvMap * vWorldDirection.x, vWorldDirection.yz ) );
	#elif defined( ENVMAP_TYPE_CUBE_UV )
		vec4 texColor = textureCubeUV( envMap, backgroundRotation * vWorldDirection, backgroundBlurriness );
	#else
		vec4 texColor = vec4( 0.0, 0.0, 0.0, 1.0 );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,d0=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,p0=`uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;
varying vec3 vWorldDirection;
void main() {
	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );
	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,m0=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
varying vec2 vHighPrecisionZW;
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vHighPrecisionZW = gl_Position.zw;
}`,_0=`#if DEPTH_PACKING == 3200
	uniform float opacity;
#endif
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
varying vec2 vHighPrecisionZW;
void main() {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#if DEPTH_PACKING == 3200
		diffuseColor.a = opacity;
	#endif
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <logdepthbuf_fragment>
	float fragCoordZ = 0.5 * vHighPrecisionZW[0] / vHighPrecisionZW[1] + 0.5;
	#if DEPTH_PACKING == 3200
		gl_FragColor = vec4( vec3( 1.0 - fragCoordZ ), opacity );
	#elif DEPTH_PACKING == 3201
		gl_FragColor = packDepthToRGBA( fragCoordZ );
	#elif DEPTH_PACKING == 3202
		gl_FragColor = vec4( packDepthToRGB( fragCoordZ ), 1.0 );
	#elif DEPTH_PACKING == 3203
		gl_FragColor = vec4( packDepthToRG( fragCoordZ ), 0.0, 1.0 );
	#endif
}`,g0=`#define DISTANCE
varying vec3 vWorldPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <clipping_planes_vertex>
	vWorldPosition = worldPosition.xyz;
}`,v0=`#define DISTANCE
uniform vec3 referencePosition;
uniform float nearDistance;
uniform float farDistance;
varying vec3 vWorldPosition;
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <clipping_planes_pars_fragment>
void main () {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	float dist = length( vWorldPosition - referencePosition );
	dist = ( dist - nearDistance ) / ( farDistance - nearDistance );
	dist = saturate( dist );
	gl_FragColor = packDepthToRGBA( dist );
}`,x0=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
}`,M0=`uniform sampler2D tEquirect;
varying vec3 vWorldDirection;
#include <common>
void main() {
	vec3 direction = normalize( vWorldDirection );
	vec2 sampleUV = equirectUv( direction );
	gl_FragColor = texture2D( tEquirect, sampleUV );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,S0=`uniform float scale;
attribute float lineDistance;
varying float vLineDistance;
#include <common>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	vLineDistance = scale * lineDistance;
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,y0=`uniform vec3 diffuse;
uniform float opacity;
uniform float dashSize;
uniform float totalSize;
varying float vLineDistance;
#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	if ( mod( vLineDistance, totalSize ) > dashSize ) {
		discard;
	}
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,E0=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#if defined ( USE_ENVMAP ) || defined ( USE_SKINNING )
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinbase_vertex>
		#include <skinnormal_vertex>
		#include <defaultnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <fog_vertex>
}`,T0=`uniform vec3 diffuse;
uniform float opacity;
#ifndef FLAT_SHADED
	varying vec3 vNormal;
#endif
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		reflectedLight.indirectDiffuse += lightMapTexel.rgb * lightMapIntensity * RECIPROCAL_PI;
	#else
		reflectedLight.indirectDiffuse += vec3( 1.0 );
	#endif
	#include <aomap_fragment>
	reflectedLight.indirectDiffuse *= diffuseColor.rgb;
	vec3 outgoingLight = reflectedLight.indirectDiffuse;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,b0=`#define LAMBERT
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,A0=`#define LAMBERT
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_lambert_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_lambert_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,w0=`#define MATCAP
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <displacementmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
	vViewPosition = - mvPosition.xyz;
}`,R0=`#define MATCAP
uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	vec3 viewDir = normalize( vViewPosition );
	vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
	vec3 y = cross( viewDir, x );
	vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5;
	#ifdef USE_MATCAP
		vec4 matcapColor = texture2D( matcap, uv );
	#else
		vec4 matcapColor = vec4( vec3( mix( 0.2, 0.8, uv.y ) ), 1.0 );
	#endif
	vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,C0=`#define NORMAL
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	vViewPosition = - mvPosition.xyz;
#endif
}`,P0=`#define NORMAL
uniform float opacity;
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <packing>
#include <uv_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( 0.0, 0.0, 0.0, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	gl_FragColor = vec4( packNormalToRGB( normal ), diffuseColor.a );
	#ifdef OPAQUE
		gl_FragColor.a = 1.0;
	#endif
}`,D0=`#define PHONG
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,L0=`#define PHONG
uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_phong_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,I0=`#define STANDARD
varying vec3 vViewPosition;
#ifdef USE_TRANSMISSION
	varying vec3 vWorldPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
#ifdef USE_TRANSMISSION
	vWorldPosition = worldPosition.xyz;
#endif
}`,U0=`#define STANDARD
#ifdef PHYSICAL
	#define IOR
	#define USE_SPECULAR
#endif
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;
#ifdef IOR
	uniform float ior;
#endif
#ifdef USE_SPECULAR
	uniform float specularIntensity;
	uniform vec3 specularColor;
	#ifdef USE_SPECULAR_COLORMAP
		uniform sampler2D specularColorMap;
	#endif
	#ifdef USE_SPECULAR_INTENSITYMAP
		uniform sampler2D specularIntensityMap;
	#endif
#endif
#ifdef USE_CLEARCOAT
	uniform float clearcoat;
	uniform float clearcoatRoughness;
#endif
#ifdef USE_DISPERSION
	uniform float dispersion;
#endif
#ifdef USE_IRIDESCENCE
	uniform float iridescence;
	uniform float iridescenceIOR;
	uniform float iridescenceThicknessMinimum;
	uniform float iridescenceThicknessMaximum;
#endif
#ifdef USE_SHEEN
	uniform vec3 sheenColor;
	uniform float sheenRoughness;
	#ifdef USE_SHEEN_COLORMAP
		uniform sampler2D sheenColorMap;
	#endif
	#ifdef USE_SHEEN_ROUGHNESSMAP
		uniform sampler2D sheenRoughnessMap;
	#endif
#endif
#ifdef USE_ANISOTROPY
	uniform vec2 anisotropyVector;
	#ifdef USE_ANISOTROPYMAP
		uniform sampler2D anisotropyMap;
	#endif
#endif
varying vec3 vViewPosition;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <iridescence_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_physical_pars_fragment>
#include <transmission_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <clearcoat_pars_fragment>
#include <iridescence_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <roughnessmap_fragment>
	#include <metalnessmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <clearcoat_normal_fragment_begin>
	#include <clearcoat_normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_physical_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;
	vec3 totalSpecular = reflectedLight.directSpecular + reflectedLight.indirectSpecular;
	#include <transmission_fragment>
	vec3 outgoingLight = totalDiffuse + totalSpecular + totalEmissiveRadiance;
	#ifdef USE_SHEEN
		float sheenEnergyComp = 1.0 - 0.157 * max3( material.sheenColor );
		outgoingLight = outgoingLight * sheenEnergyComp + sheenSpecularDirect + sheenSpecularIndirect;
	#endif
	#ifdef USE_CLEARCOAT
		float dotNVcc = saturate( dot( geometryClearcoatNormal, geometryViewDir ) );
		vec3 Fcc = F_Schlick( material.clearcoatF0, material.clearcoatF90, dotNVcc );
		outgoingLight = outgoingLight * ( 1.0 - material.clearcoat * Fcc ) + ( clearcoatSpecularDirect + clearcoatSpecularIndirect ) * material.clearcoat;
	#endif
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,N0=`#define TOON
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,F0=`#define TOON
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_toon_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_toon_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,O0=`uniform float size;
uniform float scale;
#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
#ifdef USE_POINTS_UV
	varying vec2 vUv;
	uniform mat3 uvTransform;
#endif
void main() {
	#ifdef USE_POINTS_UV
		vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	#endif
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	gl_PointSize = size;
	#ifdef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );
	#endif
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <fog_vertex>
}`,B0=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <color_pars_fragment>
#include <map_particle_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_particle_fragment>
	#include <color_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,z0=`#include <common>
#include <batching_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <shadowmap_pars_vertex>
void main() {
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,k0=`uniform vec3 color;
uniform float opacity;
#include <common>
#include <packing>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <logdepthbuf_pars_fragment>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>
void main() {
	#include <logdepthbuf_fragment>
	gl_FragColor = vec4( color, opacity * ( 1.0 - getShadowMask() ) );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,H0=`uniform float rotation;
uniform vec2 center;
#include <common>
#include <uv_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	vec4 mvPosition = modelViewMatrix[ 3 ];
	vec2 scale = vec2( length( modelMatrix[ 0 ].xyz ), length( modelMatrix[ 1 ].xyz ) );
	#ifndef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) scale *= - mvPosition.z;
	#endif
	vec2 alignedPosition = ( position.xy - ( center - vec2( 0.5 ) ) ) * scale;
	vec2 rotatedPosition;
	rotatedPosition.x = cos( rotation ) * alignedPosition.x - sin( rotation ) * alignedPosition.y;
	rotatedPosition.y = sin( rotation ) * alignedPosition.x + cos( rotation ) * alignedPosition.y;
	mvPosition.xy += rotatedPosition;
	gl_Position = projectionMatrix * mvPosition;
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,V0=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Ye={alphahash_fragment:u_,alphahash_pars_fragment:f_,alphamap_fragment:h_,alphamap_pars_fragment:d_,alphatest_fragment:p_,alphatest_pars_fragment:m_,aomap_fragment:__,aomap_pars_fragment:g_,batching_pars_vertex:v_,batching_vertex:x_,begin_vertex:M_,beginnormal_vertex:S_,bsdfs:y_,iridescence_fragment:E_,bumpmap_pars_fragment:T_,clipping_planes_fragment:b_,clipping_planes_pars_fragment:A_,clipping_planes_pars_vertex:w_,clipping_planes_vertex:R_,color_fragment:C_,color_pars_fragment:P_,color_pars_vertex:D_,color_vertex:L_,common:I_,cube_uv_reflection_fragment:U_,defaultnormal_vertex:N_,displacementmap_pars_vertex:F_,displacementmap_vertex:O_,emissivemap_fragment:B_,emissivemap_pars_fragment:z_,colorspace_fragment:k_,colorspace_pars_fragment:H_,envmap_fragment:V_,envmap_common_pars_fragment:G_,envmap_pars_fragment:W_,envmap_pars_vertex:X_,envmap_physical_pars_fragment:ng,envmap_vertex:q_,fog_vertex:Y_,fog_pars_vertex:$_,fog_fragment:K_,fog_pars_fragment:Z_,gradientmap_pars_fragment:j_,lightmap_pars_fragment:J_,lights_lambert_fragment:Q_,lights_lambert_pars_fragment:eg,lights_pars_begin:tg,lights_toon_fragment:ig,lights_toon_pars_fragment:rg,lights_phong_fragment:sg,lights_phong_pars_fragment:ag,lights_physical_fragment:og,lights_physical_pars_fragment:lg,lights_fragment_begin:cg,lights_fragment_maps:ug,lights_fragment_end:fg,logdepthbuf_fragment:hg,logdepthbuf_pars_fragment:dg,logdepthbuf_pars_vertex:pg,logdepthbuf_vertex:mg,map_fragment:_g,map_pars_fragment:gg,map_particle_fragment:vg,map_particle_pars_fragment:xg,metalnessmap_fragment:Mg,metalnessmap_pars_fragment:Sg,morphinstance_vertex:yg,morphcolor_vertex:Eg,morphnormal_vertex:Tg,morphtarget_pars_vertex:bg,morphtarget_vertex:Ag,normal_fragment_begin:wg,normal_fragment_maps:Rg,normal_pars_fragment:Cg,normal_pars_vertex:Pg,normal_vertex:Dg,normalmap_pars_fragment:Lg,clearcoat_normal_fragment_begin:Ig,clearcoat_normal_fragment_maps:Ug,clearcoat_pars_fragment:Ng,iridescence_pars_fragment:Fg,opaque_fragment:Og,packing:Bg,premultiplied_alpha_fragment:zg,project_vertex:kg,dithering_fragment:Hg,dithering_pars_fragment:Vg,roughnessmap_fragment:Gg,roughnessmap_pars_fragment:Wg,shadowmap_pars_fragment:Xg,shadowmap_pars_vertex:qg,shadowmap_vertex:Yg,shadowmask_pars_fragment:$g,skinbase_vertex:Kg,skinning_pars_vertex:Zg,skinning_vertex:jg,skinnormal_vertex:Jg,specularmap_fragment:Qg,specularmap_pars_fragment:e0,tonemapping_fragment:t0,tonemapping_pars_fragment:n0,transmission_fragment:i0,transmission_pars_fragment:r0,uv_pars_fragment:s0,uv_pars_vertex:a0,uv_vertex:o0,worldpos_vertex:l0,background_vert:c0,background_frag:u0,backgroundCube_vert:f0,backgroundCube_frag:h0,cube_vert:d0,cube_frag:p0,depth_vert:m0,depth_frag:_0,distanceRGBA_vert:g0,distanceRGBA_frag:v0,equirect_vert:x0,equirect_frag:M0,linedashed_vert:S0,linedashed_frag:y0,meshbasic_vert:E0,meshbasic_frag:T0,meshlambert_vert:b0,meshlambert_frag:A0,meshmatcap_vert:w0,meshmatcap_frag:R0,meshnormal_vert:C0,meshnormal_frag:P0,meshphong_vert:D0,meshphong_frag:L0,meshphysical_vert:I0,meshphysical_frag:U0,meshtoon_vert:N0,meshtoon_frag:F0,points_vert:O0,points_frag:B0,shadow_vert:z0,shadow_frag:k0,sprite_vert:H0,sprite_frag:V0},me={common:{diffuse:{value:new nt(16777215)},opacity:{value:1},map:{value:null},mapTransform:{value:new qe},alphaMap:{value:null},alphaMapTransform:{value:new qe},alphaTest:{value:0}},specularmap:{specularMap:{value:null},specularMapTransform:{value:new qe}},envmap:{envMap:{value:null},envMapRotation:{value:new qe},flipEnvMap:{value:-1},reflectivity:{value:1},ior:{value:1.5},refractionRatio:{value:.98}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1},aoMapTransform:{value:new qe}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1},lightMapTransform:{value:new qe}},bumpmap:{bumpMap:{value:null},bumpMapTransform:{value:new qe},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalMapTransform:{value:new qe},normalScale:{value:new Mt(1,1)}},displacementmap:{displacementMap:{value:null},displacementMapTransform:{value:new qe},displacementScale:{value:1},displacementBias:{value:0}},emissivemap:{emissiveMap:{value:null},emissiveMapTransform:{value:new qe}},metalnessmap:{metalnessMap:{value:null},metalnessMapTransform:{value:new qe}},roughnessmap:{roughnessMap:{value:null},roughnessMapTransform:{value:new qe}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new nt(16777215)}},lights:{ambientLightColor:{value:[]},lightProbe:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{}}},directionalLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMap:{value:[]},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{}}},spotLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},spotLightMap:{value:[]},spotShadowMap:{value:[]},spotLightMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{}}},pointLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMap:{value:[]},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}},ltc_1:{value:null},ltc_2:{value:null}},points:{diffuse:{value:new nt(16777215)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},alphaMap:{value:null},alphaMapTransform:{value:new qe},alphaTest:{value:0},uvTransform:{value:new qe}},sprite:{diffuse:{value:new nt(16777215)},opacity:{value:1},center:{value:new Mt(.5,.5)},rotation:{value:0},map:{value:null},mapTransform:{value:new qe},alphaMap:{value:null},alphaMapTransform:{value:new qe},alphaTest:{value:0}}},mi={basic:{uniforms:dn([me.common,me.specularmap,me.envmap,me.aomap,me.lightmap,me.fog]),vertexShader:Ye.meshbasic_vert,fragmentShader:Ye.meshbasic_frag},lambert:{uniforms:dn([me.common,me.specularmap,me.envmap,me.aomap,me.lightmap,me.emissivemap,me.bumpmap,me.normalmap,me.displacementmap,me.fog,me.lights,{emissive:{value:new nt(0)}}]),vertexShader:Ye.meshlambert_vert,fragmentShader:Ye.meshlambert_frag},phong:{uniforms:dn([me.common,me.specularmap,me.envmap,me.aomap,me.lightmap,me.emissivemap,me.bumpmap,me.normalmap,me.displacementmap,me.fog,me.lights,{emissive:{value:new nt(0)},specular:{value:new nt(1118481)},shininess:{value:30}}]),vertexShader:Ye.meshphong_vert,fragmentShader:Ye.meshphong_frag},standard:{uniforms:dn([me.common,me.envmap,me.aomap,me.lightmap,me.emissivemap,me.bumpmap,me.normalmap,me.displacementmap,me.roughnessmap,me.metalnessmap,me.fog,me.lights,{emissive:{value:new nt(0)},roughness:{value:1},metalness:{value:0},envMapIntensity:{value:1}}]),vertexShader:Ye.meshphysical_vert,fragmentShader:Ye.meshphysical_frag},toon:{uniforms:dn([me.common,me.aomap,me.lightmap,me.emissivemap,me.bumpmap,me.normalmap,me.displacementmap,me.gradientmap,me.fog,me.lights,{emissive:{value:new nt(0)}}]),vertexShader:Ye.meshtoon_vert,fragmentShader:Ye.meshtoon_frag},matcap:{uniforms:dn([me.common,me.bumpmap,me.normalmap,me.displacementmap,me.fog,{matcap:{value:null}}]),vertexShader:Ye.meshmatcap_vert,fragmentShader:Ye.meshmatcap_frag},points:{uniforms:dn([me.points,me.fog]),vertexShader:Ye.points_vert,fragmentShader:Ye.points_frag},dashed:{uniforms:dn([me.common,me.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Ye.linedashed_vert,fragmentShader:Ye.linedashed_frag},depth:{uniforms:dn([me.common,me.displacementmap]),vertexShader:Ye.depth_vert,fragmentShader:Ye.depth_frag},normal:{uniforms:dn([me.common,me.bumpmap,me.normalmap,me.displacementmap,{opacity:{value:1}}]),vertexShader:Ye.meshnormal_vert,fragmentShader:Ye.meshnormal_frag},sprite:{uniforms:dn([me.sprite,me.fog]),vertexShader:Ye.sprite_vert,fragmentShader:Ye.sprite_frag},background:{uniforms:{uvTransform:{value:new qe},t2D:{value:null},backgroundIntensity:{value:1}},vertexShader:Ye.background_vert,fragmentShader:Ye.background_frag},backgroundCube:{uniforms:{envMap:{value:null},flipEnvMap:{value:-1},backgroundBlurriness:{value:0},backgroundIntensity:{value:1},backgroundRotation:{value:new qe}},vertexShader:Ye.backgroundCube_vert,fragmentShader:Ye.backgroundCube_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Ye.cube_vert,fragmentShader:Ye.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Ye.equirect_vert,fragmentShader:Ye.equirect_frag},distanceRGBA:{uniforms:dn([me.common,me.displacementmap,{referencePosition:{value:new X},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Ye.distanceRGBA_vert,fragmentShader:Ye.distanceRGBA_frag},shadow:{uniforms:dn([me.lights,me.fog,{color:{value:new nt(0)},opacity:{value:1}}]),vertexShader:Ye.shadow_vert,fragmentShader:Ye.shadow_frag}};mi.physical={uniforms:dn([mi.standard.uniforms,{clearcoat:{value:0},clearcoatMap:{value:null},clearcoatMapTransform:{value:new qe},clearcoatNormalMap:{value:null},clearcoatNormalMapTransform:{value:new qe},clearcoatNormalScale:{value:new Mt(1,1)},clearcoatRoughness:{value:0},clearcoatRoughnessMap:{value:null},clearcoatRoughnessMapTransform:{value:new qe},dispersion:{value:0},iridescence:{value:0},iridescenceMap:{value:null},iridescenceMapTransform:{value:new qe},iridescenceIOR:{value:1.3},iridescenceThicknessMinimum:{value:100},iridescenceThicknessMaximum:{value:400},iridescenceThicknessMap:{value:null},iridescenceThicknessMapTransform:{value:new qe},sheen:{value:0},sheenColor:{value:new nt(0)},sheenColorMap:{value:null},sheenColorMapTransform:{value:new qe},sheenRoughness:{value:1},sheenRoughnessMap:{value:null},sheenRoughnessMapTransform:{value:new qe},transmission:{value:0},transmissionMap:{value:null},transmissionMapTransform:{value:new qe},transmissionSamplerSize:{value:new Mt},transmissionSamplerMap:{value:null},thickness:{value:0},thicknessMap:{value:null},thicknessMapTransform:{value:new qe},attenuationDistance:{value:0},attenuationColor:{value:new nt(0)},specularColor:{value:new nt(1,1,1)},specularColorMap:{value:null},specularColorMapTransform:{value:new qe},specularIntensity:{value:1},specularIntensityMap:{value:null},specularIntensityMapTransform:{value:new qe},anisotropyVector:{value:new Mt},anisotropyMap:{value:null},anisotropyMapTransform:{value:new qe}}]),vertexShader:Ye.meshphysical_vert,fragmentShader:Ye.meshphysical_frag};const oo={r:0,b:0,g:0},xr=new ki,G0=new Lt;function W0(r,e,t,n,i,s,a){const o=new nt(0);let l=s===!0?0:1,c,u,h=null,d=0,f=null;function g(E){let x=E.isScene===!0?E.background:null;return x&&x.isTexture&&(x=(E.backgroundBlurriness>0?t:e).get(x)),x}function _(E){let x=!1;const R=g(E);R===null?p(o,l):R&&R.isColor&&(p(R,1),x=!0);const w=r.xr.getEnvironmentBlendMode();w==="additive"?n.buffers.color.setClear(0,0,0,1,a):w==="alpha-blend"&&n.buffers.color.setClear(0,0,0,0,a),(r.autoClear||x)&&(n.buffers.depth.setTest(!0),n.buffers.depth.setMask(!0),n.buffers.color.setMask(!0),r.clear(r.autoClearColor,r.autoClearDepth,r.autoClearStencil))}function m(E,x){const R=g(x);R&&(R.isCubeTexture||R.mapping===nl)?(u===void 0&&(u=new Ui(new Fa(1,1,1),new lr({name:"BackgroundCubeMaterial",uniforms:Is(mi.backgroundCube.uniforms),vertexShader:mi.backgroundCube.vertexShader,fragmentShader:mi.backgroundCube.fragmentShader,side:Tn,depthTest:!1,depthWrite:!1,fog:!1})),u.geometry.deleteAttribute("normal"),u.geometry.deleteAttribute("uv"),u.onBeforeRender=function(w,b,C){this.matrixWorld.copyPosition(C.matrixWorld)},Object.defineProperty(u.material,"envMap",{get:function(){return this.uniforms.envMap.value}}),i.update(u)),xr.copy(x.backgroundRotation),xr.x*=-1,xr.y*=-1,xr.z*=-1,R.isCubeTexture&&R.isRenderTargetTexture===!1&&(xr.y*=-1,xr.z*=-1),u.material.uniforms.envMap.value=R,u.material.uniforms.flipEnvMap.value=R.isCubeTexture&&R.isRenderTargetTexture===!1?-1:1,u.material.uniforms.backgroundBlurriness.value=x.backgroundBlurriness,u.material.uniforms.backgroundIntensity.value=x.backgroundIntensity,u.material.uniforms.backgroundRotation.value.setFromMatrix4(G0.makeRotationFromEuler(xr)),u.material.toneMapped=ut.getTransfer(R.colorSpace)!==pt,(h!==R||d!==R.version||f!==r.toneMapping)&&(u.material.needsUpdate=!0,h=R,d=R.version,f=r.toneMapping),u.layers.enableAll(),E.unshift(u,u.geometry,u.material,0,0,null)):R&&R.isTexture&&(c===void 0&&(c=new Ui(new il(2,2),new lr({name:"BackgroundMaterial",uniforms:Is(mi.background.uniforms),vertexShader:mi.background.vertexShader,fragmentShader:mi.background.fragmentShader,side:or,depthTest:!1,depthWrite:!1,fog:!1})),c.geometry.deleteAttribute("normal"),Object.defineProperty(c.material,"map",{get:function(){return this.uniforms.t2D.value}}),i.update(c)),c.material.uniforms.t2D.value=R,c.material.uniforms.backgroundIntensity.value=x.backgroundIntensity,c.material.toneMapped=ut.getTransfer(R.colorSpace)!==pt,R.matrixAutoUpdate===!0&&R.updateMatrix(),c.material.uniforms.uvTransform.value.copy(R.matrix),(h!==R||d!==R.version||f!==r.toneMapping)&&(c.material.needsUpdate=!0,h=R,d=R.version,f=r.toneMapping),c.layers.enableAll(),E.unshift(c,c.geometry,c.material,0,0,null))}function p(E,x){E.getRGB(oo,td(r)),n.buffers.color.setClear(oo.r,oo.g,oo.b,x,a)}function T(){u!==void 0&&(u.geometry.dispose(),u.material.dispose()),c!==void 0&&(c.geometry.dispose(),c.material.dispose())}return{getClearColor:function(){return o},setClearColor:function(E,x=1){o.set(E),l=x,p(o,l)},getClearAlpha:function(){return l},setClearAlpha:function(E){l=E,p(o,l)},render:_,addToRenderList:m,dispose:T}}function X0(r,e){const t=r.getParameter(r.MAX_VERTEX_ATTRIBS),n={},i=d(null);let s=i,a=!1;function o(v,P,U,O,G){let Y=!1;const H=h(O,U,P);s!==H&&(s=H,c(s.object)),Y=f(v,O,U,G),Y&&g(v,O,U,G),G!==null&&e.update(G,r.ELEMENT_ARRAY_BUFFER),(Y||a)&&(a=!1,x(v,P,U,O),G!==null&&r.bindBuffer(r.ELEMENT_ARRAY_BUFFER,e.get(G).buffer))}function l(){return r.createVertexArray()}function c(v){return r.bindVertexArray(v)}function u(v){return r.deleteVertexArray(v)}function h(v,P,U){const O=U.wireframe===!0;let G=n[v.id];G===void 0&&(G={},n[v.id]=G);let Y=G[P.id];Y===void 0&&(Y={},G[P.id]=Y);let H=Y[O];return H===void 0&&(H=d(l()),Y[O]=H),H}function d(v){const P=[],U=[],O=[];for(let G=0;G<t;G++)P[G]=0,U[G]=0,O[G]=0;return{geometry:null,program:null,wireframe:!1,newAttributes:P,enabledAttributes:U,attributeDivisors:O,object:v,attributes:{},index:null}}function f(v,P,U,O){const G=s.attributes,Y=P.attributes;let H=0;const q=U.getAttributes();for(const k in q)if(q[k].location>=0){const D=G[k];let ue=Y[k];if(ue===void 0&&(k==="instanceMatrix"&&v.instanceMatrix&&(ue=v.instanceMatrix),k==="instanceColor"&&v.instanceColor&&(ue=v.instanceColor)),D===void 0||D.attribute!==ue||ue&&D.data!==ue.data)return!0;H++}return s.attributesNum!==H||s.index!==O}function g(v,P,U,O){const G={},Y=P.attributes;let H=0;const q=U.getAttributes();for(const k in q)if(q[k].location>=0){let D=Y[k];D===void 0&&(k==="instanceMatrix"&&v.instanceMatrix&&(D=v.instanceMatrix),k==="instanceColor"&&v.instanceColor&&(D=v.instanceColor));const ue={};ue.attribute=D,D&&D.data&&(ue.data=D.data),G[k]=ue,H++}s.attributes=G,s.attributesNum=H,s.index=O}function _(){const v=s.newAttributes;for(let P=0,U=v.length;P<U;P++)v[P]=0}function m(v){p(v,0)}function p(v,P){const U=s.newAttributes,O=s.enabledAttributes,G=s.attributeDivisors;U[v]=1,O[v]===0&&(r.enableVertexAttribArray(v),O[v]=1),G[v]!==P&&(r.vertexAttribDivisor(v,P),G[v]=P)}function T(){const v=s.newAttributes,P=s.enabledAttributes;for(let U=0,O=P.length;U<O;U++)P[U]!==v[U]&&(r.disableVertexAttribArray(U),P[U]=0)}function E(v,P,U,O,G,Y,H){H===!0?r.vertexAttribIPointer(v,P,U,G,Y):r.vertexAttribPointer(v,P,U,O,G,Y)}function x(v,P,U,O){_();const G=O.attributes,Y=U.getAttributes(),H=P.defaultAttributeValues;for(const q in Y){const k=Y[q];if(k.location>=0){let ne=G[q];if(ne===void 0&&(q==="instanceMatrix"&&v.instanceMatrix&&(ne=v.instanceMatrix),q==="instanceColor"&&v.instanceColor&&(ne=v.instanceColor)),ne!==void 0){const D=ne.normalized,ue=ne.itemSize,Ie=e.get(ne);if(Ie===void 0)continue;const $e=Ie.buffer,K=Ie.type,te=Ie.bytesPerElement,_e=K===r.INT||K===r.UNSIGNED_INT||ne.gpuType===mu;if(ne.isInterleavedBufferAttribute){const ie=ne.data,Ee=ie.stride,we=ne.offset;if(ie.isInstancedInterleavedBuffer){for(let He=0;He<k.locationSize;He++)p(k.location+He,ie.meshPerAttribute);v.isInstancedMesh!==!0&&O._maxInstanceCount===void 0&&(O._maxInstanceCount=ie.meshPerAttribute*ie.count)}else for(let He=0;He<k.locationSize;He++)m(k.location+He);r.bindBuffer(r.ARRAY_BUFFER,$e);for(let He=0;He<k.locationSize;He++)E(k.location+He,ue/k.locationSize,K,D,Ee*te,(we+ue/k.locationSize*He)*te,_e)}else{if(ne.isInstancedBufferAttribute){for(let ie=0;ie<k.locationSize;ie++)p(k.location+ie,ne.meshPerAttribute);v.isInstancedMesh!==!0&&O._maxInstanceCount===void 0&&(O._maxInstanceCount=ne.meshPerAttribute*ne.count)}else for(let ie=0;ie<k.locationSize;ie++)m(k.location+ie);r.bindBuffer(r.ARRAY_BUFFER,$e);for(let ie=0;ie<k.locationSize;ie++)E(k.location+ie,ue/k.locationSize,K,D,ue*te,ue/k.locationSize*ie*te,_e)}}else if(H!==void 0){const D=H[q];if(D!==void 0)switch(D.length){case 2:r.vertexAttrib2fv(k.location,D);break;case 3:r.vertexAttrib3fv(k.location,D);break;case 4:r.vertexAttrib4fv(k.location,D);break;default:r.vertexAttrib1fv(k.location,D)}}}}T()}function R(){C();for(const v in n){const P=n[v];for(const U in P){const O=P[U];for(const G in O)u(O[G].object),delete O[G];delete P[U]}delete n[v]}}function w(v){if(n[v.id]===void 0)return;const P=n[v.id];for(const U in P){const O=P[U];for(const G in O)u(O[G].object),delete O[G];delete P[U]}delete n[v.id]}function b(v){for(const P in n){const U=n[P];if(U[v.id]===void 0)continue;const O=U[v.id];for(const G in O)u(O[G].object),delete O[G];delete U[v.id]}}function C(){M(),a=!0,s!==i&&(s=i,c(s.object))}function M(){i.geometry=null,i.program=null,i.wireframe=!1}return{setup:o,reset:C,resetDefaultState:M,dispose:R,releaseStatesOfGeometry:w,releaseStatesOfProgram:b,initAttributes:_,enableAttribute:m,disableUnusedAttributes:T}}function q0(r,e,t){let n;function i(c){n=c}function s(c,u){r.drawArrays(n,c,u),t.update(u,n,1)}function a(c,u,h){h!==0&&(r.drawArraysInstanced(n,c,u,h),t.update(u,n,h))}function o(c,u,h){if(h===0)return;e.get("WEBGL_multi_draw").multiDrawArraysWEBGL(n,c,0,u,0,h);let f=0;for(let g=0;g<h;g++)f+=u[g];t.update(f,n,1)}function l(c,u,h,d){if(h===0)return;const f=e.get("WEBGL_multi_draw");if(f===null)for(let g=0;g<c.length;g++)a(c[g],u[g],d[g]);else{f.multiDrawArraysInstancedWEBGL(n,c,0,u,0,d,0,h);let g=0;for(let _=0;_<h;_++)g+=u[_]*d[_];t.update(g,n,1)}}this.setMode=i,this.render=s,this.renderInstances=a,this.renderMultiDraw=o,this.renderMultiDrawInstances=l}function Y0(r,e,t,n){let i;function s(){if(i!==void 0)return i;if(e.has("EXT_texture_filter_anisotropic")===!0){const b=e.get("EXT_texture_filter_anisotropic");i=r.getParameter(b.MAX_TEXTURE_MAX_ANISOTROPY_EXT)}else i=0;return i}function a(b){return!(b!==ui&&n.convert(b)!==r.getParameter(r.IMPLEMENTATION_COLOR_READ_FORMAT))}function o(b){const C=b===Da&&(e.has("EXT_color_buffer_half_float")||e.has("EXT_color_buffer_float"));return!(b!==zi&&n.convert(b)!==r.getParameter(r.IMPLEMENTATION_COLOR_READ_TYPE)&&b!==Li&&!C)}function l(b){if(b==="highp"){if(r.getShaderPrecisionFormat(r.VERTEX_SHADER,r.HIGH_FLOAT).precision>0&&r.getShaderPrecisionFormat(r.FRAGMENT_SHADER,r.HIGH_FLOAT).precision>0)return"highp";b="mediump"}return b==="mediump"&&r.getShaderPrecisionFormat(r.VERTEX_SHADER,r.MEDIUM_FLOAT).precision>0&&r.getShaderPrecisionFormat(r.FRAGMENT_SHADER,r.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}let c=t.precision!==void 0?t.precision:"highp";const u=l(c);u!==c&&(console.warn("THREE.WebGLRenderer:",c,"not supported, using",u,"instead."),c=u);const h=t.logarithmicDepthBuffer===!0,d=t.reverseDepthBuffer===!0&&e.has("EXT_clip_control"),f=r.getParameter(r.MAX_TEXTURE_IMAGE_UNITS),g=r.getParameter(r.MAX_VERTEX_TEXTURE_IMAGE_UNITS),_=r.getParameter(r.MAX_TEXTURE_SIZE),m=r.getParameter(r.MAX_CUBE_MAP_TEXTURE_SIZE),p=r.getParameter(r.MAX_VERTEX_ATTRIBS),T=r.getParameter(r.MAX_VERTEX_UNIFORM_VECTORS),E=r.getParameter(r.MAX_VARYING_VECTORS),x=r.getParameter(r.MAX_FRAGMENT_UNIFORM_VECTORS),R=g>0,w=r.getParameter(r.MAX_SAMPLES);return{isWebGL2:!0,getMaxAnisotropy:s,getMaxPrecision:l,textureFormatReadable:a,textureTypeReadable:o,precision:c,logarithmicDepthBuffer:h,reverseDepthBuffer:d,maxTextures:f,maxVertexTextures:g,maxTextureSize:_,maxCubemapSize:m,maxAttributes:p,maxVertexUniforms:T,maxVaryings:E,maxFragmentUniforms:x,vertexTextures:R,maxSamples:w}}function $0(r){const e=this;let t=null,n=0,i=!1,s=!1;const a=new Er,o=new qe,l={value:null,needsUpdate:!1};this.uniform=l,this.numPlanes=0,this.numIntersection=0,this.init=function(h,d){const f=h.length!==0||d||n!==0||i;return i=d,n=h.length,f},this.beginShadows=function(){s=!0,u(null)},this.endShadows=function(){s=!1},this.setGlobalState=function(h,d){t=u(h,d,0)},this.setState=function(h,d,f){const g=h.clippingPlanes,_=h.clipIntersection,m=h.clipShadows,p=r.get(h);if(!i||g===null||g.length===0||s&&!m)s?u(null):c();else{const T=s?0:n,E=T*4;let x=p.clippingState||null;l.value=x,x=u(g,d,E,f);for(let R=0;R!==E;++R)x[R]=t[R];p.clippingState=x,this.numIntersection=_?this.numPlanes:0,this.numPlanes+=T}};function c(){l.value!==t&&(l.value=t,l.needsUpdate=n>0),e.numPlanes=n,e.numIntersection=0}function u(h,d,f,g){const _=h!==null?h.length:0;let m=null;if(_!==0){if(m=l.value,g!==!0||m===null){const p=f+_*4,T=d.matrixWorldInverse;o.getNormalMatrix(T),(m===null||m.length<p)&&(m=new Float32Array(p));for(let E=0,x=f;E!==_;++E,x+=4)a.copy(h[E]).applyMatrix4(T,o),a.normal.toArray(m,x),m[x+3]=a.constant}l.value=m,l.needsUpdate=!0}return e.numPlanes=_,e.numIntersection=0,m}}function K0(r){let e=new WeakMap;function t(a,o){return o===fc?a.mapping=Rs:o===hc&&(a.mapping=Cs),a}function n(a){if(a&&a.isTexture){const o=a.mapping;if(o===fc||o===hc)if(e.has(a)){const l=e.get(a).texture;return t(l,a.mapping)}else{const l=a.image;if(l&&l.height>0){const c=new Zm(l.height);return c.fromEquirectangularTexture(r,a),e.set(a,c),a.addEventListener("dispose",i),t(c.texture,a.mapping)}else return null}}return a}function i(a){const o=a.target;o.removeEventListener("dispose",i);const l=e.get(o);l!==void 0&&(e.delete(o),l.dispose())}function s(){e=new WeakMap}return{get:n,dispose:s}}const ps=4,wf=[.125,.215,.35,.446,.526,.582],Cr=20,Ul=new s_,Rf=new nt;let Nl=null,Fl=0,Ol=0,Bl=!1;const Tr=(1+Math.sqrt(5))/2,os=1/Tr,Cf=[new X(-Tr,os,0),new X(Tr,os,0),new X(-os,0,Tr),new X(os,0,Tr),new X(0,Tr,-os),new X(0,Tr,os),new X(-1,1,-1),new X(1,1,-1),new X(-1,1,1),new X(1,1,1)];class Pf{constructor(e){this._renderer=e,this._pingPongRenderTarget=null,this._lodMax=0,this._cubeSize=0,this._lodPlanes=[],this._sizeLods=[],this._sigmas=[],this._blurMaterial=null,this._cubemapMaterial=null,this._equirectMaterial=null,this._compileMaterial(this._blurMaterial)}fromScene(e,t=0,n=.1,i=100){Nl=this._renderer.getRenderTarget(),Fl=this._renderer.getActiveCubeFace(),Ol=this._renderer.getActiveMipmapLevel(),Bl=this._renderer.xr.enabled,this._renderer.xr.enabled=!1,this._setSize(256);const s=this._allocateTargets();return s.depthBuffer=!0,this._sceneToCubeUV(e,n,i,s),t>0&&this._blur(s,0,0,t),this._applyPMREM(s),this._cleanup(s),s}fromEquirectangular(e,t=null){return this._fromTexture(e,t)}fromCubemap(e,t=null){return this._fromTexture(e,t)}compileCubemapShader(){this._cubemapMaterial===null&&(this._cubemapMaterial=If(),this._compileMaterial(this._cubemapMaterial))}compileEquirectangularShader(){this._equirectMaterial===null&&(this._equirectMaterial=Lf(),this._compileMaterial(this._equirectMaterial))}dispose(){this._dispose(),this._cubemapMaterial!==null&&this._cubemapMaterial.dispose(),this._equirectMaterial!==null&&this._equirectMaterial.dispose()}_setSize(e){this._lodMax=Math.floor(Math.log2(e)),this._cubeSize=Math.pow(2,this._lodMax)}_dispose(){this._blurMaterial!==null&&this._blurMaterial.dispose(),this._pingPongRenderTarget!==null&&this._pingPongRenderTarget.dispose();for(let e=0;e<this._lodPlanes.length;e++)this._lodPlanes[e].dispose()}_cleanup(e){this._renderer.setRenderTarget(Nl,Fl,Ol),this._renderer.xr.enabled=Bl,e.scissorTest=!1,lo(e,0,0,e.width,e.height)}_fromTexture(e,t){e.mapping===Rs||e.mapping===Cs?this._setSize(e.image.length===0?16:e.image[0].width||e.image[0].image.width):this._setSize(e.image.width/4),Nl=this._renderer.getRenderTarget(),Fl=this._renderer.getActiveCubeFace(),Ol=this._renderer.getActiveMipmapLevel(),Bl=this._renderer.xr.enabled,this._renderer.xr.enabled=!1;const n=t||this._allocateTargets();return this._textureToCubeUV(e,n),this._applyPMREM(n),this._cleanup(n),n}_allocateTargets(){const e=3*Math.max(this._cubeSize,112),t=4*this._cubeSize,n={magFilter:gi,minFilter:gi,generateMipmaps:!1,type:Da,format:ui,colorSpace:Ls,depthBuffer:!1},i=Df(e,t,n);if(this._pingPongRenderTarget===null||this._pingPongRenderTarget.width!==e||this._pingPongRenderTarget.height!==t){this._pingPongRenderTarget!==null&&this._dispose(),this._pingPongRenderTarget=Df(e,t,n);const{_lodMax:s}=this;({sizeLods:this._sizeLods,lodPlanes:this._lodPlanes,sigmas:this._sigmas}=Z0(s)),this._blurMaterial=j0(s,e,t)}return i}_compileMaterial(e){const t=new Ui(this._lodPlanes[0],e);this._renderer.compile(t,Ul)}_sceneToCubeUV(e,t,n,i){const o=new Jn(90,1,t,n),l=[1,-1,1,1,1,1],c=[1,1,1,-1,-1,-1],u=this._renderer,h=u.autoClear,d=u.toneMapping;u.getClearColor(Rf),u.toneMapping=ir,u.autoClear=!1;const f=new Jh({name:"PMREM.Background",side:Tn,depthWrite:!1,depthTest:!1}),g=new Ui(new Fa,f);let _=!1;const m=e.background;m?m.isColor&&(f.color.copy(m),e.background=null,_=!0):(f.color.copy(Rf),_=!0);for(let p=0;p<6;p++){const T=p%3;T===0?(o.up.set(0,l[p],0),o.lookAt(c[p],0,0)):T===1?(o.up.set(0,0,l[p]),o.lookAt(0,c[p],0)):(o.up.set(0,l[p],0),o.lookAt(0,0,c[p]));const E=this._cubeSize;lo(i,T*E,p>2?E:0,E,E),u.setRenderTarget(i),_&&u.render(g,o),u.render(e,o)}g.geometry.dispose(),g.material.dispose(),u.toneMapping=d,u.autoClear=h,e.background=m}_textureToCubeUV(e,t){const n=this._renderer,i=e.mapping===Rs||e.mapping===Cs;i?(this._cubemapMaterial===null&&(this._cubemapMaterial=If()),this._cubemapMaterial.uniforms.flipEnvMap.value=e.isRenderTargetTexture===!1?-1:1):this._equirectMaterial===null&&(this._equirectMaterial=Lf());const s=i?this._cubemapMaterial:this._equirectMaterial,a=new Ui(this._lodPlanes[0],s),o=s.uniforms;o.envMap.value=e;const l=this._cubeSize;lo(t,0,0,3*l,2*l),n.setRenderTarget(t),n.render(a,Ul)}_applyPMREM(e){const t=this._renderer,n=t.autoClear;t.autoClear=!1;const i=this._lodPlanes.length;for(let s=1;s<i;s++){const a=Math.sqrt(this._sigmas[s]*this._sigmas[s]-this._sigmas[s-1]*this._sigmas[s-1]),o=Cf[(i-s-1)%Cf.length];this._blur(e,s-1,s,a,o)}t.autoClear=n}_blur(e,t,n,i,s){const a=this._pingPongRenderTarget;this._halfBlur(e,a,t,n,i,"latitudinal",s),this._halfBlur(a,e,n,n,i,"longitudinal",s)}_halfBlur(e,t,n,i,s,a,o){const l=this._renderer,c=this._blurMaterial;a!=="latitudinal"&&a!=="longitudinal"&&console.error("blur direction must be either latitudinal or longitudinal!");const u=3,h=new Ui(this._lodPlanes[i],c),d=c.uniforms,f=this._sizeLods[n]-1,g=isFinite(s)?Math.PI/(2*f):2*Math.PI/(2*Cr-1),_=s/g,m=isFinite(s)?1+Math.floor(u*_):Cr;m>Cr&&console.warn(`sigmaRadians, ${s}, is too large and will clip, as it requested ${m} samples when the maximum is set to ${Cr}`);const p=[];let T=0;for(let b=0;b<Cr;++b){const C=b/_,M=Math.exp(-C*C/2);p.push(M),b===0?T+=M:b<m&&(T+=2*M)}for(let b=0;b<p.length;b++)p[b]=p[b]/T;d.envMap.value=e.texture,d.samples.value=m,d.weights.value=p,d.latitudinal.value=a==="latitudinal",o&&(d.poleAxis.value=o);const{_lodMax:E}=this;d.dTheta.value=g,d.mipInt.value=E-n;const x=this._sizeLods[i],R=3*x*(i>E-ps?i-E+ps:0),w=4*(this._cubeSize-x);lo(t,R,w,3*x,2*x),l.setRenderTarget(t),l.render(h,Ul)}}function Z0(r){const e=[],t=[],n=[];let i=r;const s=r-ps+1+wf.length;for(let a=0;a<s;a++){const o=Math.pow(2,i);t.push(o);let l=1/o;a>r-ps?l=wf[a-r+ps-1]:a===0&&(l=0),n.push(l);const c=1/(o-2),u=-c,h=1+c,d=[u,u,h,u,h,h,u,u,h,h,u,h],f=6,g=6,_=3,m=2,p=1,T=new Float32Array(_*g*f),E=new Float32Array(m*g*f),x=new Float32Array(p*g*f);for(let w=0;w<f;w++){const b=w%3*2/3-1,C=w>2?0:-1,M=[b,C,0,b+2/3,C,0,b+2/3,C+1,0,b,C,0,b+2/3,C+1,0,b,C+1,0];T.set(M,_*g*w),E.set(d,m*g*w);const v=[w,w,w,w,w,w];x.set(v,p*g*w)}const R=new hi;R.setAttribute("position",new En(T,_)),R.setAttribute("uv",new En(E,m)),R.setAttribute("faceIndex",new En(x,p)),e.push(R),i>ps&&i--}return{lodPlanes:e,sizeLods:t,sigmas:n}}function Df(r,e,t){const n=new Vr(r,e,t);return n.texture.mapping=nl,n.texture.name="PMREM.cubeUv",n.scissorTest=!0,n}function lo(r,e,t,n,i){r.viewport.set(e,t,n,i),r.scissor.set(e,t,n,i)}function j0(r,e,t){const n=new Float32Array(Cr),i=new X(0,1,0);return new lr({name:"SphericalGaussianBlur",defines:{n:Cr,CUBEUV_TEXEL_WIDTH:1/e,CUBEUV_TEXEL_HEIGHT:1/t,CUBEUV_MAX_MIP:`${r}.0`},uniforms:{envMap:{value:null},samples:{value:1},weights:{value:n},latitudinal:{value:!1},dTheta:{value:0},mipInt:{value:0},poleAxis:{value:i}},vertexShader:yu(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;
			uniform int samples;
			uniform float weights[ n ];
			uniform bool latitudinal;
			uniform float dTheta;
			uniform float mipInt;
			uniform vec3 poleAxis;

			#define ENVMAP_TYPE_CUBE_UV
			#include <cube_uv_reflection_fragment>

			vec3 getSample( float theta, vec3 axis ) {

				float cosTheta = cos( theta );
				// Rodrigues' axis-angle rotation
				vec3 sampleDirection = vOutputDirection * cosTheta
					+ cross( axis, vOutputDirection ) * sin( theta )
					+ axis * dot( axis, vOutputDirection ) * ( 1.0 - cosTheta );

				return bilinearCubeUV( envMap, sampleDirection, mipInt );

			}

			void main() {

				vec3 axis = latitudinal ? poleAxis : cross( poleAxis, vOutputDirection );

				if ( all( equal( axis, vec3( 0.0 ) ) ) ) {

					axis = vec3( vOutputDirection.z, 0.0, - vOutputDirection.x );

				}

				axis = normalize( axis );

				gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
				gl_FragColor.rgb += weights[ 0 ] * getSample( 0.0, axis );

				for ( int i = 1; i < n; i++ ) {

					if ( i >= samples ) {

						break;

					}

					float theta = dTheta * float( i );
					gl_FragColor.rgb += weights[ i ] * getSample( -1.0 * theta, axis );
					gl_FragColor.rgb += weights[ i ] * getSample( theta, axis );

				}

			}
		`,blending:nr,depthTest:!1,depthWrite:!1})}function Lf(){return new lr({name:"EquirectangularToCubeUV",uniforms:{envMap:{value:null}},vertexShader:yu(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;

			#include <common>

			void main() {

				vec3 outputDirection = normalize( vOutputDirection );
				vec2 uv = equirectUv( outputDirection );

				gl_FragColor = vec4( texture2D ( envMap, uv ).rgb, 1.0 );

			}
		`,blending:nr,depthTest:!1,depthWrite:!1})}function If(){return new lr({name:"CubemapToCubeUV",uniforms:{envMap:{value:null},flipEnvMap:{value:-1}},vertexShader:yu(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			uniform float flipEnvMap;

			varying vec3 vOutputDirection;

			uniform samplerCube envMap;

			void main() {

				gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

			}
		`,blending:nr,depthTest:!1,depthWrite:!1})}function yu(){return`

		precision mediump float;
		precision mediump int;

		attribute float faceIndex;

		varying vec3 vOutputDirection;

		// RH coordinate system; PMREM face-indexing convention
		vec3 getDirection( vec2 uv, float face ) {

			uv = 2.0 * uv - 1.0;

			vec3 direction = vec3( uv, 1.0 );

			if ( face == 0.0 ) {

				direction = direction.zyx; // ( 1, v, u ) pos x

			} else if ( face == 1.0 ) {

				direction = direction.xzy;
				direction.xz *= -1.0; // ( -u, 1, -v ) pos y

			} else if ( face == 2.0 ) {

				direction.x *= -1.0; // ( -u, v, 1 ) pos z

			} else if ( face == 3.0 ) {

				direction = direction.zyx;
				direction.xz *= -1.0; // ( -1, v, -u ) neg x

			} else if ( face == 4.0 ) {

				direction = direction.xzy;
				direction.xy *= -1.0; // ( -u, -1, v ) neg y

			} else if ( face == 5.0 ) {

				direction.z *= -1.0; // ( u, v, -1 ) neg z

			}

			return direction;

		}

		void main() {

			vOutputDirection = getDirection( uv, faceIndex );
			gl_Position = vec4( position, 1.0 );

		}
	`}function J0(r){let e=new WeakMap,t=null;function n(o){if(o&&o.isTexture){const l=o.mapping,c=l===fc||l===hc,u=l===Rs||l===Cs;if(c||u){let h=e.get(o);const d=h!==void 0?h.texture.pmremVersion:0;if(o.isRenderTargetTexture&&o.pmremVersion!==d)return t===null&&(t=new Pf(r)),h=c?t.fromEquirectangular(o,h):t.fromCubemap(o,h),h.texture.pmremVersion=o.pmremVersion,e.set(o,h),h.texture;if(h!==void 0)return h.texture;{const f=o.image;return c&&f&&f.height>0||u&&f&&i(f)?(t===null&&(t=new Pf(r)),h=c?t.fromEquirectangular(o):t.fromCubemap(o),h.texture.pmremVersion=o.pmremVersion,e.set(o,h),o.addEventListener("dispose",s),h.texture):null}}}return o}function i(o){let l=0;const c=6;for(let u=0;u<c;u++)o[u]!==void 0&&l++;return l===c}function s(o){const l=o.target;l.removeEventListener("dispose",s);const c=e.get(l);c!==void 0&&(e.delete(l),c.dispose())}function a(){e=new WeakMap,t!==null&&(t.dispose(),t=null)}return{get:n,dispose:a}}function Q0(r){const e={};function t(n){if(e[n]!==void 0)return e[n];let i;switch(n){case"WEBGL_depth_texture":i=r.getExtension("WEBGL_depth_texture")||r.getExtension("MOZ_WEBGL_depth_texture")||r.getExtension("WEBKIT_WEBGL_depth_texture");break;case"EXT_texture_filter_anisotropic":i=r.getExtension("EXT_texture_filter_anisotropic")||r.getExtension("MOZ_EXT_texture_filter_anisotropic")||r.getExtension("WEBKIT_EXT_texture_filter_anisotropic");break;case"WEBGL_compressed_texture_s3tc":i=r.getExtension("WEBGL_compressed_texture_s3tc")||r.getExtension("MOZ_WEBGL_compressed_texture_s3tc")||r.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc");break;case"WEBGL_compressed_texture_pvrtc":i=r.getExtension("WEBGL_compressed_texture_pvrtc")||r.getExtension("WEBKIT_WEBGL_compressed_texture_pvrtc");break;default:i=r.getExtension(n)}return e[n]=i,i}return{has:function(n){return t(n)!==null},init:function(){t("EXT_color_buffer_float"),t("WEBGL_clip_cull_distance"),t("OES_texture_float_linear"),t("EXT_color_buffer_half_float"),t("WEBGL_multisampled_render_to_texture"),t("WEBGL_render_shared_exponent")},get:function(n){const i=t(n);return i===null&&fs("THREE.WebGLRenderer: "+n+" extension not supported."),i}}}function ev(r,e,t,n){const i={},s=new WeakMap;function a(h){const d=h.target;d.index!==null&&e.remove(d.index);for(const g in d.attributes)e.remove(d.attributes[g]);d.removeEventListener("dispose",a),delete i[d.id];const f=s.get(d);f&&(e.remove(f),s.delete(d)),n.releaseStatesOfGeometry(d),d.isInstancedBufferGeometry===!0&&delete d._maxInstanceCount,t.memory.geometries--}function o(h,d){return i[d.id]===!0||(d.addEventListener("dispose",a),i[d.id]=!0,t.memory.geometries++),d}function l(h){const d=h.attributes;for(const f in d)e.update(d[f],r.ARRAY_BUFFER)}function c(h){const d=[],f=h.index,g=h.attributes.position;let _=0;if(f!==null){const T=f.array;_=f.version;for(let E=0,x=T.length;E<x;E+=3){const R=T[E+0],w=T[E+1],b=T[E+2];d.push(R,w,w,b,b,R)}}else if(g!==void 0){const T=g.array;_=g.version;for(let E=0,x=T.length/3-1;E<x;E+=3){const R=E+0,w=E+1,b=E+2;d.push(R,w,w,b,b,R)}}else return;const m=new(Yh(d)?ed:Qh)(d,1);m.version=_;const p=s.get(h);p&&e.remove(p),s.set(h,m)}function u(h){const d=s.get(h);if(d){const f=h.index;f!==null&&d.version<f.version&&c(h)}else c(h);return s.get(h)}return{get:o,update:l,getWireframeAttribute:u}}function tv(r,e,t){let n;function i(d){n=d}let s,a;function o(d){s=d.type,a=d.bytesPerElement}function l(d,f){r.drawElements(n,f,s,d*a),t.update(f,n,1)}function c(d,f,g){g!==0&&(r.drawElementsInstanced(n,f,s,d*a,g),t.update(f,n,g))}function u(d,f,g){if(g===0)return;e.get("WEBGL_multi_draw").multiDrawElementsWEBGL(n,f,0,s,d,0,g);let m=0;for(let p=0;p<g;p++)m+=f[p];t.update(m,n,1)}function h(d,f,g,_){if(g===0)return;const m=e.get("WEBGL_multi_draw");if(m===null)for(let p=0;p<d.length;p++)c(d[p]/a,f[p],_[p]);else{m.multiDrawElementsInstancedWEBGL(n,f,0,s,d,0,_,0,g);let p=0;for(let T=0;T<g;T++)p+=f[T]*_[T];t.update(p,n,1)}}this.setMode=i,this.setIndex=o,this.render=l,this.renderInstances=c,this.renderMultiDraw=u,this.renderMultiDrawInstances=h}function nv(r){const e={geometries:0,textures:0},t={frame:0,calls:0,triangles:0,points:0,lines:0};function n(s,a,o){switch(t.calls++,a){case r.TRIANGLES:t.triangles+=o*(s/3);break;case r.LINES:t.lines+=o*(s/2);break;case r.LINE_STRIP:t.lines+=o*(s-1);break;case r.LINE_LOOP:t.lines+=o*s;break;case r.POINTS:t.points+=o*s;break;default:console.error("THREE.WebGLInfo: Unknown draw mode:",a);break}}function i(){t.calls=0,t.triangles=0,t.points=0,t.lines=0}return{memory:e,render:t,programs:null,autoReset:!0,reset:i,update:n}}function iv(r,e,t){const n=new WeakMap,i=new Nt;function s(a,o,l){const c=a.morphTargetInfluences,u=o.morphAttributes.position||o.morphAttributes.normal||o.morphAttributes.color,h=u!==void 0?u.length:0;let d=n.get(o);if(d===void 0||d.count!==h){let v=function(){C.dispose(),n.delete(o),o.removeEventListener("dispose",v)};var f=v;d!==void 0&&d.texture.dispose();const g=o.morphAttributes.position!==void 0,_=o.morphAttributes.normal!==void 0,m=o.morphAttributes.color!==void 0,p=o.morphAttributes.position||[],T=o.morphAttributes.normal||[],E=o.morphAttributes.color||[];let x=0;g===!0&&(x=1),_===!0&&(x=2),m===!0&&(x=3);let R=o.attributes.position.count*x,w=1;R>e.maxTextureSize&&(w=Math.ceil(R/e.maxTextureSize),R=e.maxTextureSize);const b=new Float32Array(R*w*4*h),C=new Kh(b,R,w,h);C.type=Li,C.needsUpdate=!0;const M=x*4;for(let P=0;P<h;P++){const U=p[P],O=T[P],G=E[P],Y=R*w*4*P;for(let H=0;H<U.count;H++){const q=H*M;g===!0&&(i.fromBufferAttribute(U,H),b[Y+q+0]=i.x,b[Y+q+1]=i.y,b[Y+q+2]=i.z,b[Y+q+3]=0),_===!0&&(i.fromBufferAttribute(O,H),b[Y+q+4]=i.x,b[Y+q+5]=i.y,b[Y+q+6]=i.z,b[Y+q+7]=0),m===!0&&(i.fromBufferAttribute(G,H),b[Y+q+8]=i.x,b[Y+q+9]=i.y,b[Y+q+10]=i.z,b[Y+q+11]=G.itemSize===4?i.w:1)}}d={count:h,texture:C,size:new Mt(R,w)},n.set(o,d),o.addEventListener("dispose",v)}if(a.isInstancedMesh===!0&&a.morphTexture!==null)l.getUniforms().setValue(r,"morphTexture",a.morphTexture,t);else{let g=0;for(let m=0;m<c.length;m++)g+=c[m];const _=o.morphTargetsRelative?1:1-g;l.getUniforms().setValue(r,"morphTargetBaseInfluence",_),l.getUniforms().setValue(r,"morphTargetInfluences",c)}l.getUniforms().setValue(r,"morphTargetsTexture",d.texture,t),l.getUniforms().setValue(r,"morphTargetsTextureSize",d.size)}return{update:s}}function rv(r,e,t,n){let i=new WeakMap;function s(l){const c=n.render.frame,u=l.geometry,h=e.get(l,u);if(i.get(h)!==c&&(e.update(h),i.set(h,c)),l.isInstancedMesh&&(l.hasEventListener("dispose",o)===!1&&l.addEventListener("dispose",o),i.get(l)!==c&&(t.update(l.instanceMatrix,r.ARRAY_BUFFER),l.instanceColor!==null&&t.update(l.instanceColor,r.ARRAY_BUFFER),i.set(l,c))),l.isSkinnedMesh){const d=l.skeleton;i.get(d)!==c&&(d.update(),i.set(d,c))}return h}function a(){i=new WeakMap}function o(l){const c=l.target;c.removeEventListener("dispose",o),t.remove(c.instanceMatrix),c.instanceColor!==null&&t.remove(c.instanceColor)}return{update:s,dispose:a}}const cd=new bn,Uf=new od(1,1),ud=new Kh,fd=new Um,hd=new id,Nf=[],Ff=[],Of=new Float32Array(16),Bf=new Float32Array(9),zf=new Float32Array(4);function Gs(r,e,t){const n=r[0];if(n<=0||n>0)return r;const i=e*t;let s=Nf[i];if(s===void 0&&(s=new Float32Array(i),Nf[i]=s),e!==0){n.toArray(s,0);for(let a=1,o=0;a!==e;++a)o+=t,r[a].toArray(s,o)}return s}function qt(r,e){if(r.length!==e.length)return!1;for(let t=0,n=r.length;t<n;t++)if(r[t]!==e[t])return!1;return!0}function Yt(r,e){for(let t=0,n=e.length;t<n;t++)r[t]=e[t]}function rl(r,e){let t=Ff[e];t===void 0&&(t=new Int32Array(e),Ff[e]=t);for(let n=0;n!==e;++n)t[n]=r.allocateTextureUnit();return t}function sv(r,e){const t=this.cache;t[0]!==e&&(r.uniform1f(this.addr,e),t[0]=e)}function av(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y)&&(r.uniform2f(this.addr,e.x,e.y),t[0]=e.x,t[1]=e.y);else{if(qt(t,e))return;r.uniform2fv(this.addr,e),Yt(t,e)}}function ov(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z)&&(r.uniform3f(this.addr,e.x,e.y,e.z),t[0]=e.x,t[1]=e.y,t[2]=e.z);else if(e.r!==void 0)(t[0]!==e.r||t[1]!==e.g||t[2]!==e.b)&&(r.uniform3f(this.addr,e.r,e.g,e.b),t[0]=e.r,t[1]=e.g,t[2]=e.b);else{if(qt(t,e))return;r.uniform3fv(this.addr,e),Yt(t,e)}}function lv(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z||t[3]!==e.w)&&(r.uniform4f(this.addr,e.x,e.y,e.z,e.w),t[0]=e.x,t[1]=e.y,t[2]=e.z,t[3]=e.w);else{if(qt(t,e))return;r.uniform4fv(this.addr,e),Yt(t,e)}}function cv(r,e){const t=this.cache,n=e.elements;if(n===void 0){if(qt(t,e))return;r.uniformMatrix2fv(this.addr,!1,e),Yt(t,e)}else{if(qt(t,n))return;zf.set(n),r.uniformMatrix2fv(this.addr,!1,zf),Yt(t,n)}}function uv(r,e){const t=this.cache,n=e.elements;if(n===void 0){if(qt(t,e))return;r.uniformMatrix3fv(this.addr,!1,e),Yt(t,e)}else{if(qt(t,n))return;Bf.set(n),r.uniformMatrix3fv(this.addr,!1,Bf),Yt(t,n)}}function fv(r,e){const t=this.cache,n=e.elements;if(n===void 0){if(qt(t,e))return;r.uniformMatrix4fv(this.addr,!1,e),Yt(t,e)}else{if(qt(t,n))return;Of.set(n),r.uniformMatrix4fv(this.addr,!1,Of),Yt(t,n)}}function hv(r,e){const t=this.cache;t[0]!==e&&(r.uniform1i(this.addr,e),t[0]=e)}function dv(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y)&&(r.uniform2i(this.addr,e.x,e.y),t[0]=e.x,t[1]=e.y);else{if(qt(t,e))return;r.uniform2iv(this.addr,e),Yt(t,e)}}function pv(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z)&&(r.uniform3i(this.addr,e.x,e.y,e.z),t[0]=e.x,t[1]=e.y,t[2]=e.z);else{if(qt(t,e))return;r.uniform3iv(this.addr,e),Yt(t,e)}}function mv(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z||t[3]!==e.w)&&(r.uniform4i(this.addr,e.x,e.y,e.z,e.w),t[0]=e.x,t[1]=e.y,t[2]=e.z,t[3]=e.w);else{if(qt(t,e))return;r.uniform4iv(this.addr,e),Yt(t,e)}}function _v(r,e){const t=this.cache;t[0]!==e&&(r.uniform1ui(this.addr,e),t[0]=e)}function gv(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y)&&(r.uniform2ui(this.addr,e.x,e.y),t[0]=e.x,t[1]=e.y);else{if(qt(t,e))return;r.uniform2uiv(this.addr,e),Yt(t,e)}}function vv(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z)&&(r.uniform3ui(this.addr,e.x,e.y,e.z),t[0]=e.x,t[1]=e.y,t[2]=e.z);else{if(qt(t,e))return;r.uniform3uiv(this.addr,e),Yt(t,e)}}function xv(r,e){const t=this.cache;if(e.x!==void 0)(t[0]!==e.x||t[1]!==e.y||t[2]!==e.z||t[3]!==e.w)&&(r.uniform4ui(this.addr,e.x,e.y,e.z,e.w),t[0]=e.x,t[1]=e.y,t[2]=e.z,t[3]=e.w);else{if(qt(t,e))return;r.uniform4uiv(this.addr,e),Yt(t,e)}}function Mv(r,e,t){const n=this.cache,i=t.allocateTextureUnit();n[0]!==i&&(r.uniform1i(this.addr,i),n[0]=i);let s;this.type===r.SAMPLER_2D_SHADOW?(Uf.compareFunction=qh,s=Uf):s=cd,t.setTexture2D(e||s,i)}function Sv(r,e,t){const n=this.cache,i=t.allocateTextureUnit();n[0]!==i&&(r.uniform1i(this.addr,i),n[0]=i),t.setTexture3D(e||fd,i)}function yv(r,e,t){const n=this.cache,i=t.allocateTextureUnit();n[0]!==i&&(r.uniform1i(this.addr,i),n[0]=i),t.setTextureCube(e||hd,i)}function Ev(r,e,t){const n=this.cache,i=t.allocateTextureUnit();n[0]!==i&&(r.uniform1i(this.addr,i),n[0]=i),t.setTexture2DArray(e||ud,i)}function Tv(r){switch(r){case 5126:return sv;case 35664:return av;case 35665:return ov;case 35666:return lv;case 35674:return cv;case 35675:return uv;case 35676:return fv;case 5124:case 35670:return hv;case 35667:case 35671:return dv;case 35668:case 35672:return pv;case 35669:case 35673:return mv;case 5125:return _v;case 36294:return gv;case 36295:return vv;case 36296:return xv;case 35678:case 36198:case 36298:case 36306:case 35682:return Mv;case 35679:case 36299:case 36307:return Sv;case 35680:case 36300:case 36308:case 36293:return yv;case 36289:case 36303:case 36311:case 36292:return Ev}}function bv(r,e){r.uniform1fv(this.addr,e)}function Av(r,e){const t=Gs(e,this.size,2);r.uniform2fv(this.addr,t)}function wv(r,e){const t=Gs(e,this.size,3);r.uniform3fv(this.addr,t)}function Rv(r,e){const t=Gs(e,this.size,4);r.uniform4fv(this.addr,t)}function Cv(r,e){const t=Gs(e,this.size,4);r.uniformMatrix2fv(this.addr,!1,t)}function Pv(r,e){const t=Gs(e,this.size,9);r.uniformMatrix3fv(this.addr,!1,t)}function Dv(r,e){const t=Gs(e,this.size,16);r.uniformMatrix4fv(this.addr,!1,t)}function Lv(r,e){r.uniform1iv(this.addr,e)}function Iv(r,e){r.uniform2iv(this.addr,e)}function Uv(r,e){r.uniform3iv(this.addr,e)}function Nv(r,e){r.uniform4iv(this.addr,e)}function Fv(r,e){r.uniform1uiv(this.addr,e)}function Ov(r,e){r.uniform2uiv(this.addr,e)}function Bv(r,e){r.uniform3uiv(this.addr,e)}function zv(r,e){r.uniform4uiv(this.addr,e)}function kv(r,e,t){const n=this.cache,i=e.length,s=rl(t,i);qt(n,s)||(r.uniform1iv(this.addr,s),Yt(n,s));for(let a=0;a!==i;++a)t.setTexture2D(e[a]||cd,s[a])}function Hv(r,e,t){const n=this.cache,i=e.length,s=rl(t,i);qt(n,s)||(r.uniform1iv(this.addr,s),Yt(n,s));for(let a=0;a!==i;++a)t.setTexture3D(e[a]||fd,s[a])}function Vv(r,e,t){const n=this.cache,i=e.length,s=rl(t,i);qt(n,s)||(r.uniform1iv(this.addr,s),Yt(n,s));for(let a=0;a!==i;++a)t.setTextureCube(e[a]||hd,s[a])}function Gv(r,e,t){const n=this.cache,i=e.length,s=rl(t,i);qt(n,s)||(r.uniform1iv(this.addr,s),Yt(n,s));for(let a=0;a!==i;++a)t.setTexture2DArray(e[a]||ud,s[a])}function Wv(r){switch(r){case 5126:return bv;case 35664:return Av;case 35665:return wv;case 35666:return Rv;case 35674:return Cv;case 35675:return Pv;case 35676:return Dv;case 5124:case 35670:return Lv;case 35667:case 35671:return Iv;case 35668:case 35672:return Uv;case 35669:case 35673:return Nv;case 5125:return Fv;case 36294:return Ov;case 36295:return Bv;case 36296:return zv;case 35678:case 36198:case 36298:case 36306:case 35682:return kv;case 35679:case 36299:case 36307:return Hv;case 35680:case 36300:case 36308:case 36293:return Vv;case 36289:case 36303:case 36311:case 36292:return Gv}}class Xv{constructor(e,t,n){this.id=e,this.addr=n,this.cache=[],this.type=t.type,this.setValue=Tv(t.type)}}class qv{constructor(e,t,n){this.id=e,this.addr=n,this.cache=[],this.type=t.type,this.size=t.size,this.setValue=Wv(t.type)}}class Yv{constructor(e){this.id=e,this.seq=[],this.map={}}setValue(e,t,n){const i=this.seq;for(let s=0,a=i.length;s!==a;++s){const o=i[s];o.setValue(e,t[o.id],n)}}}const zl=/(\w+)(\])?(\[|\.)?/g;function kf(r,e){r.seq.push(e),r.map[e.id]=e}function $v(r,e,t){const n=r.name,i=n.length;for(zl.lastIndex=0;;){const s=zl.exec(n),a=zl.lastIndex;let o=s[1];const l=s[2]==="]",c=s[3];if(l&&(o=o|0),c===void 0||c==="["&&a+2===i){kf(t,c===void 0?new Xv(o,r,e):new qv(o,r,e));break}else{let h=t.map[o];h===void 0&&(h=new Yv(o),kf(t,h)),t=h}}}class Co{constructor(e,t){this.seq=[],this.map={};const n=e.getProgramParameter(t,e.ACTIVE_UNIFORMS);for(let i=0;i<n;++i){const s=e.getActiveUniform(t,i),a=e.getUniformLocation(t,s.name);$v(s,a,this)}}setValue(e,t,n,i){const s=this.map[t];s!==void 0&&s.setValue(e,n,i)}setOptional(e,t,n){const i=t[n];i!==void 0&&this.setValue(e,n,i)}static upload(e,t,n,i){for(let s=0,a=t.length;s!==a;++s){const o=t[s],l=n[o.id];l.needsUpdate!==!1&&o.setValue(e,l.value,i)}}static seqWithValue(e,t){const n=[];for(let i=0,s=e.length;i!==s;++i){const a=e[i];a.id in t&&n.push(a)}return n}}function Hf(r,e,t){const n=r.createShader(e);return r.shaderSource(n,t),r.compileShader(n),n}const Kv=37297;let Zv=0;function jv(r,e){const t=r.split(`
`),n=[],i=Math.max(e-6,0),s=Math.min(e+6,t.length);for(let a=i;a<s;a++){const o=a+1;n.push(`${o===e?">":" "} ${o}: ${t[a]}`)}return n.join(`
`)}const Vf=new qe;function Jv(r){ut._getMatrix(Vf,ut.workingColorSpace,r);const e=`mat3( ${Vf.elements.map(t=>t.toFixed(4))} )`;switch(ut.getTransfer(r)){case ko:return[e,"LinearTransferOETF"];case pt:return[e,"sRGBTransferOETF"];default:return console.warn("THREE.WebGLProgram: Unsupported color space: ",r),[e,"LinearTransferOETF"]}}function Gf(r,e,t){const n=r.getShaderParameter(e,r.COMPILE_STATUS),i=r.getShaderInfoLog(e).trim();if(n&&i==="")return"";const s=/ERROR: 0:(\d+)/.exec(i);if(s){const a=parseInt(s[1]);return t.toUpperCase()+`

`+i+`

`+jv(r.getShaderSource(e),a)}else return i}function Qv(r,e){const t=Jv(e);return[`vec4 ${r}( vec4 value ) {`,`	return ${t[1]}( vec4( value.rgb * ${t[0]}, value.a ) );`,"}"].join(`
`)}function ex(r,e){let t;switch(e){case sm:t="Linear";break;case am:t="Reinhard";break;case om:t="Cineon";break;case lm:t="ACESFilmic";break;case um:t="AgX";break;case fm:t="Neutral";break;case cm:t="Custom";break;default:console.warn("THREE.WebGLProgram: Unsupported toneMapping:",e),t="Linear"}return"vec3 "+r+"( vec3 color ) { return "+t+"ToneMapping( color ); }"}const co=new X;function tx(){ut.getLuminanceCoefficients(co);const r=co.x.toFixed(4),e=co.y.toFixed(4),t=co.z.toFixed(4);return["float luminance( const in vec3 rgb ) {",`	const vec3 weights = vec3( ${r}, ${e}, ${t} );`,"	return dot( weights, rgb );","}"].join(`
`)}function nx(r){return[r.extensionClipCullDistance?"#extension GL_ANGLE_clip_cull_distance : require":"",r.extensionMultiDraw?"#extension GL_ANGLE_multi_draw : require":""].filter(ea).join(`
`)}function ix(r){const e=[];for(const t in r){const n=r[t];n!==!1&&e.push("#define "+t+" "+n)}return e.join(`
`)}function rx(r,e){const t={},n=r.getProgramParameter(e,r.ACTIVE_ATTRIBUTES);for(let i=0;i<n;i++){const s=r.getActiveAttrib(e,i),a=s.name;let o=1;s.type===r.FLOAT_MAT2&&(o=2),s.type===r.FLOAT_MAT3&&(o=3),s.type===r.FLOAT_MAT4&&(o=4),t[a]={type:s.type,location:r.getAttribLocation(e,a),locationSize:o}}return t}function ea(r){return r!==""}function Wf(r,e){const t=e.numSpotLightShadows+e.numSpotLightMaps-e.numSpotLightShadowsWithMaps;return r.replace(/NUM_DIR_LIGHTS/g,e.numDirLights).replace(/NUM_SPOT_LIGHTS/g,e.numSpotLights).replace(/NUM_SPOT_LIGHT_MAPS/g,e.numSpotLightMaps).replace(/NUM_SPOT_LIGHT_COORDS/g,t).replace(/NUM_RECT_AREA_LIGHTS/g,e.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,e.numPointLights).replace(/NUM_HEMI_LIGHTS/g,e.numHemiLights).replace(/NUM_DIR_LIGHT_SHADOWS/g,e.numDirLightShadows).replace(/NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS/g,e.numSpotLightShadowsWithMaps).replace(/NUM_SPOT_LIGHT_SHADOWS/g,e.numSpotLightShadows).replace(/NUM_POINT_LIGHT_SHADOWS/g,e.numPointLightShadows)}function Xf(r,e){return r.replace(/NUM_CLIPPING_PLANES/g,e.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,e.numClippingPlanes-e.numClipIntersection)}const sx=/^[ \t]*#include +<([\w\d./]+)>/gm;function Gc(r){return r.replace(sx,ox)}const ax=new Map;function ox(r,e){let t=Ye[e];if(t===void 0){const n=ax.get(e);if(n!==void 0)t=Ye[n],console.warn('THREE.WebGLRenderer: Shader chunk "%s" has been deprecated. Use "%s" instead.',e,n);else throw new Error("Can not resolve #include <"+e+">")}return Gc(t)}const lx=/#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;function qf(r){return r.replace(lx,cx)}function cx(r,e,t,n){let i="";for(let s=parseInt(e);s<parseInt(t);s++)i+=n.replace(/\[\s*i\s*\]/g,"[ "+s+" ]").replace(/UNROLLED_LOOP_INDEX/g,s);return i}function Yf(r){let e=`precision ${r.precision} float;
	precision ${r.precision} int;
	precision ${r.precision} sampler2D;
	precision ${r.precision} samplerCube;
	precision ${r.precision} sampler3D;
	precision ${r.precision} sampler2DArray;
	precision ${r.precision} sampler2DShadow;
	precision ${r.precision} samplerCubeShadow;
	precision ${r.precision} sampler2DArrayShadow;
	precision ${r.precision} isampler2D;
	precision ${r.precision} isampler3D;
	precision ${r.precision} isamplerCube;
	precision ${r.precision} isampler2DArray;
	precision ${r.precision} usampler2D;
	precision ${r.precision} usampler3D;
	precision ${r.precision} usamplerCube;
	precision ${r.precision} usampler2DArray;
	`;return r.precision==="highp"?e+=`
#define HIGH_PRECISION`:r.precision==="mediump"?e+=`
#define MEDIUM_PRECISION`:r.precision==="lowp"&&(e+=`
#define LOW_PRECISION`),e}function ux(r){let e="SHADOWMAP_TYPE_BASIC";return r.shadowMapType===Ih?e="SHADOWMAP_TYPE_PCF":r.shadowMapType===Bp?e="SHADOWMAP_TYPE_PCF_SOFT":r.shadowMapType===wi&&(e="SHADOWMAP_TYPE_VSM"),e}function fx(r){let e="ENVMAP_TYPE_CUBE";if(r.envMap)switch(r.envMapMode){case Rs:case Cs:e="ENVMAP_TYPE_CUBE";break;case nl:e="ENVMAP_TYPE_CUBE_UV";break}return e}function hx(r){let e="ENVMAP_MODE_REFLECTION";if(r.envMap)switch(r.envMapMode){case Cs:e="ENVMAP_MODE_REFRACTION";break}return e}function dx(r){let e="ENVMAP_BLENDING_NONE";if(r.envMap)switch(r.combine){case Uh:e="ENVMAP_BLENDING_MULTIPLY";break;case im:e="ENVMAP_BLENDING_MIX";break;case rm:e="ENVMAP_BLENDING_ADD";break}return e}function px(r){const e=r.envMapCubeUVHeight;if(e===null)return null;const t=Math.log2(e)-2,n=1/e;return{texelWidth:1/(3*Math.max(Math.pow(2,t),7*16)),texelHeight:n,maxMip:t}}function mx(r,e,t,n){const i=r.getContext(),s=t.defines;let a=t.vertexShader,o=t.fragmentShader;const l=ux(t),c=fx(t),u=hx(t),h=dx(t),d=px(t),f=nx(t),g=ix(s),_=i.createProgram();let m,p,T=t.glslVersion?"#version "+t.glslVersion+`
`:"";t.isRawShaderMaterial?(m=["#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g].filter(ea).join(`
`),m.length>0&&(m+=`
`),p=["#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g].filter(ea).join(`
`),p.length>0&&(p+=`
`)):(m=[Yf(t),"#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g,t.extensionClipCullDistance?"#define USE_CLIP_DISTANCE":"",t.batching?"#define USE_BATCHING":"",t.batchingColor?"#define USE_BATCHING_COLOR":"",t.instancing?"#define USE_INSTANCING":"",t.instancingColor?"#define USE_INSTANCING_COLOR":"",t.instancingMorph?"#define USE_INSTANCING_MORPH":"",t.useFog&&t.fog?"#define USE_FOG":"",t.useFog&&t.fogExp2?"#define FOG_EXP2":"",t.map?"#define USE_MAP":"",t.envMap?"#define USE_ENVMAP":"",t.envMap?"#define "+u:"",t.lightMap?"#define USE_LIGHTMAP":"",t.aoMap?"#define USE_AOMAP":"",t.bumpMap?"#define USE_BUMPMAP":"",t.normalMap?"#define USE_NORMALMAP":"",t.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",t.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",t.displacementMap?"#define USE_DISPLACEMENTMAP":"",t.emissiveMap?"#define USE_EMISSIVEMAP":"",t.anisotropy?"#define USE_ANISOTROPY":"",t.anisotropyMap?"#define USE_ANISOTROPYMAP":"",t.clearcoatMap?"#define USE_CLEARCOATMAP":"",t.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",t.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",t.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",t.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",t.specularMap?"#define USE_SPECULARMAP":"",t.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",t.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",t.roughnessMap?"#define USE_ROUGHNESSMAP":"",t.metalnessMap?"#define USE_METALNESSMAP":"",t.alphaMap?"#define USE_ALPHAMAP":"",t.alphaHash?"#define USE_ALPHAHASH":"",t.transmission?"#define USE_TRANSMISSION":"",t.transmissionMap?"#define USE_TRANSMISSIONMAP":"",t.thicknessMap?"#define USE_THICKNESSMAP":"",t.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",t.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",t.mapUv?"#define MAP_UV "+t.mapUv:"",t.alphaMapUv?"#define ALPHAMAP_UV "+t.alphaMapUv:"",t.lightMapUv?"#define LIGHTMAP_UV "+t.lightMapUv:"",t.aoMapUv?"#define AOMAP_UV "+t.aoMapUv:"",t.emissiveMapUv?"#define EMISSIVEMAP_UV "+t.emissiveMapUv:"",t.bumpMapUv?"#define BUMPMAP_UV "+t.bumpMapUv:"",t.normalMapUv?"#define NORMALMAP_UV "+t.normalMapUv:"",t.displacementMapUv?"#define DISPLACEMENTMAP_UV "+t.displacementMapUv:"",t.metalnessMapUv?"#define METALNESSMAP_UV "+t.metalnessMapUv:"",t.roughnessMapUv?"#define ROUGHNESSMAP_UV "+t.roughnessMapUv:"",t.anisotropyMapUv?"#define ANISOTROPYMAP_UV "+t.anisotropyMapUv:"",t.clearcoatMapUv?"#define CLEARCOATMAP_UV "+t.clearcoatMapUv:"",t.clearcoatNormalMapUv?"#define CLEARCOAT_NORMALMAP_UV "+t.clearcoatNormalMapUv:"",t.clearcoatRoughnessMapUv?"#define CLEARCOAT_ROUGHNESSMAP_UV "+t.clearcoatRoughnessMapUv:"",t.iridescenceMapUv?"#define IRIDESCENCEMAP_UV "+t.iridescenceMapUv:"",t.iridescenceThicknessMapUv?"#define IRIDESCENCE_THICKNESSMAP_UV "+t.iridescenceThicknessMapUv:"",t.sheenColorMapUv?"#define SHEEN_COLORMAP_UV "+t.sheenColorMapUv:"",t.sheenRoughnessMapUv?"#define SHEEN_ROUGHNESSMAP_UV "+t.sheenRoughnessMapUv:"",t.specularMapUv?"#define SPECULARMAP_UV "+t.specularMapUv:"",t.specularColorMapUv?"#define SPECULAR_COLORMAP_UV "+t.specularColorMapUv:"",t.specularIntensityMapUv?"#define SPECULAR_INTENSITYMAP_UV "+t.specularIntensityMapUv:"",t.transmissionMapUv?"#define TRANSMISSIONMAP_UV "+t.transmissionMapUv:"",t.thicknessMapUv?"#define THICKNESSMAP_UV "+t.thicknessMapUv:"",t.vertexTangents&&t.flatShading===!1?"#define USE_TANGENT":"",t.vertexColors?"#define USE_COLOR":"",t.vertexAlphas?"#define USE_COLOR_ALPHA":"",t.vertexUv1s?"#define USE_UV1":"",t.vertexUv2s?"#define USE_UV2":"",t.vertexUv3s?"#define USE_UV3":"",t.pointsUvs?"#define USE_POINTS_UV":"",t.flatShading?"#define FLAT_SHADED":"",t.skinning?"#define USE_SKINNING":"",t.morphTargets?"#define USE_MORPHTARGETS":"",t.morphNormals&&t.flatShading===!1?"#define USE_MORPHNORMALS":"",t.morphColors?"#define USE_MORPHCOLORS":"",t.morphTargetsCount>0?"#define MORPHTARGETS_TEXTURE_STRIDE "+t.morphTextureStride:"",t.morphTargetsCount>0?"#define MORPHTARGETS_COUNT "+t.morphTargetsCount:"",t.doubleSided?"#define DOUBLE_SIDED":"",t.flipSided?"#define FLIP_SIDED":"",t.shadowMapEnabled?"#define USE_SHADOWMAP":"",t.shadowMapEnabled?"#define "+l:"",t.sizeAttenuation?"#define USE_SIZEATTENUATION":"",t.numLightProbes>0?"#define USE_LIGHT_PROBES":"",t.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",t.reverseDepthBuffer?"#define USE_REVERSEDEPTHBUF":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;","#ifdef USE_INSTANCING","	attribute mat4 instanceMatrix;","#endif","#ifdef USE_INSTANCING_COLOR","	attribute vec3 instanceColor;","#endif","#ifdef USE_INSTANCING_MORPH","	uniform sampler2D morphTexture;","#endif","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_UV1","	attribute vec2 uv1;","#endif","#ifdef USE_UV2","	attribute vec2 uv2;","#endif","#ifdef USE_UV3","	attribute vec2 uv3;","#endif","#ifdef USE_TANGENT","	attribute vec4 tangent;","#endif","#if defined( USE_COLOR_ALPHA )","	attribute vec4 color;","#elif defined( USE_COLOR )","	attribute vec3 color;","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(ea).join(`
`),p=[Yf(t),"#define SHADER_TYPE "+t.shaderType,"#define SHADER_NAME "+t.shaderName,g,t.useFog&&t.fog?"#define USE_FOG":"",t.useFog&&t.fogExp2?"#define FOG_EXP2":"",t.alphaToCoverage?"#define ALPHA_TO_COVERAGE":"",t.map?"#define USE_MAP":"",t.matcap?"#define USE_MATCAP":"",t.envMap?"#define USE_ENVMAP":"",t.envMap?"#define "+c:"",t.envMap?"#define "+u:"",t.envMap?"#define "+h:"",d?"#define CUBEUV_TEXEL_WIDTH "+d.texelWidth:"",d?"#define CUBEUV_TEXEL_HEIGHT "+d.texelHeight:"",d?"#define CUBEUV_MAX_MIP "+d.maxMip+".0":"",t.lightMap?"#define USE_LIGHTMAP":"",t.aoMap?"#define USE_AOMAP":"",t.bumpMap?"#define USE_BUMPMAP":"",t.normalMap?"#define USE_NORMALMAP":"",t.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",t.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",t.emissiveMap?"#define USE_EMISSIVEMAP":"",t.anisotropy?"#define USE_ANISOTROPY":"",t.anisotropyMap?"#define USE_ANISOTROPYMAP":"",t.clearcoat?"#define USE_CLEARCOAT":"",t.clearcoatMap?"#define USE_CLEARCOATMAP":"",t.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",t.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",t.dispersion?"#define USE_DISPERSION":"",t.iridescence?"#define USE_IRIDESCENCE":"",t.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",t.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",t.specularMap?"#define USE_SPECULARMAP":"",t.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",t.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",t.roughnessMap?"#define USE_ROUGHNESSMAP":"",t.metalnessMap?"#define USE_METALNESSMAP":"",t.alphaMap?"#define USE_ALPHAMAP":"",t.alphaTest?"#define USE_ALPHATEST":"",t.alphaHash?"#define USE_ALPHAHASH":"",t.sheen?"#define USE_SHEEN":"",t.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",t.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",t.transmission?"#define USE_TRANSMISSION":"",t.transmissionMap?"#define USE_TRANSMISSIONMAP":"",t.thicknessMap?"#define USE_THICKNESSMAP":"",t.vertexTangents&&t.flatShading===!1?"#define USE_TANGENT":"",t.vertexColors||t.instancingColor||t.batchingColor?"#define USE_COLOR":"",t.vertexAlphas?"#define USE_COLOR_ALPHA":"",t.vertexUv1s?"#define USE_UV1":"",t.vertexUv2s?"#define USE_UV2":"",t.vertexUv3s?"#define USE_UV3":"",t.pointsUvs?"#define USE_POINTS_UV":"",t.gradientMap?"#define USE_GRADIENTMAP":"",t.flatShading?"#define FLAT_SHADED":"",t.doubleSided?"#define DOUBLE_SIDED":"",t.flipSided?"#define FLIP_SIDED":"",t.shadowMapEnabled?"#define USE_SHADOWMAP":"",t.shadowMapEnabled?"#define "+l:"",t.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",t.numLightProbes>0?"#define USE_LIGHT_PROBES":"",t.decodeVideoTexture?"#define DECODE_VIDEO_TEXTURE":"",t.decodeVideoTextureEmissive?"#define DECODE_VIDEO_TEXTURE_EMISSIVE":"",t.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",t.reverseDepthBuffer?"#define USE_REVERSEDEPTHBUF":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;",t.toneMapping!==ir?"#define TONE_MAPPING":"",t.toneMapping!==ir?Ye.tonemapping_pars_fragment:"",t.toneMapping!==ir?ex("toneMapping",t.toneMapping):"",t.dithering?"#define DITHERING":"",t.opaque?"#define OPAQUE":"",Ye.colorspace_pars_fragment,Qv("linearToOutputTexel",t.outputColorSpace),tx(),t.useDepthPacking?"#define DEPTH_PACKING "+t.depthPacking:"",`
`].filter(ea).join(`
`)),a=Gc(a),a=Wf(a,t),a=Xf(a,t),o=Gc(o),o=Wf(o,t),o=Xf(o,t),a=qf(a),o=qf(o),t.isRawShaderMaterial!==!0&&(T=`#version 300 es
`,m=[f,"#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+m,p=["#define varying in",t.glslVersion===ef?"":"layout(location = 0) out highp vec4 pc_fragColor;",t.glslVersion===ef?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+p);const E=T+m+a,x=T+p+o,R=Hf(i,i.VERTEX_SHADER,E),w=Hf(i,i.FRAGMENT_SHADER,x);i.attachShader(_,R),i.attachShader(_,w),t.index0AttributeName!==void 0?i.bindAttribLocation(_,0,t.index0AttributeName):t.morphTargets===!0&&i.bindAttribLocation(_,0,"position"),i.linkProgram(_);function b(P){if(r.debug.checkShaderErrors){const U=i.getProgramInfoLog(_).trim(),O=i.getShaderInfoLog(R).trim(),G=i.getShaderInfoLog(w).trim();let Y=!0,H=!0;if(i.getProgramParameter(_,i.LINK_STATUS)===!1)if(Y=!1,typeof r.debug.onShaderError=="function")r.debug.onShaderError(i,_,R,w);else{const q=Gf(i,R,"vertex"),k=Gf(i,w,"fragment");console.error("THREE.WebGLProgram: Shader Error "+i.getError()+" - VALIDATE_STATUS "+i.getProgramParameter(_,i.VALIDATE_STATUS)+`

Material Name: `+P.name+`
Material Type: `+P.type+`

Program Info Log: `+U+`
`+q+`
`+k)}else U!==""?console.warn("THREE.WebGLProgram: Program Info Log:",U):(O===""||G==="")&&(H=!1);H&&(P.diagnostics={runnable:Y,programLog:U,vertexShader:{log:O,prefix:m},fragmentShader:{log:G,prefix:p}})}i.deleteShader(R),i.deleteShader(w),C=new Co(i,_),M=rx(i,_)}let C;this.getUniforms=function(){return C===void 0&&b(this),C};let M;this.getAttributes=function(){return M===void 0&&b(this),M};let v=t.rendererExtensionParallelShaderCompile===!1;return this.isReady=function(){return v===!1&&(v=i.getProgramParameter(_,Kv)),v},this.destroy=function(){n.releaseStatesOfProgram(this),i.deleteProgram(_),this.program=void 0},this.type=t.shaderType,this.name=t.shaderName,this.id=Zv++,this.cacheKey=e,this.usedTimes=1,this.program=_,this.vertexShader=R,this.fragmentShader=w,this}let _x=0;class gx{constructor(){this.shaderCache=new Map,this.materialCache=new Map}update(e){const t=e.vertexShader,n=e.fragmentShader,i=this._getShaderStage(t),s=this._getShaderStage(n),a=this._getShaderCacheForMaterial(e);return a.has(i)===!1&&(a.add(i),i.usedTimes++),a.has(s)===!1&&(a.add(s),s.usedTimes++),this}remove(e){const t=this.materialCache.get(e);for(const n of t)n.usedTimes--,n.usedTimes===0&&this.shaderCache.delete(n.code);return this.materialCache.delete(e),this}getVertexShaderID(e){return this._getShaderStage(e.vertexShader).id}getFragmentShaderID(e){return this._getShaderStage(e.fragmentShader).id}dispose(){this.shaderCache.clear(),this.materialCache.clear()}_getShaderCacheForMaterial(e){const t=this.materialCache;let n=t.get(e);return n===void 0&&(n=new Set,t.set(e,n)),n}_getShaderStage(e){const t=this.shaderCache;let n=t.get(e);return n===void 0&&(n=new vx(e),t.set(e,n)),n}}class vx{constructor(e){this.id=_x++,this.code=e,this.usedTimes=0}}function xx(r,e,t,n,i,s,a){const o=new Zh,l=new gx,c=new Set,u=[],h=i.logarithmicDepthBuffer,d=i.vertexTextures;let f=i.precision;const g={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distanceRGBA",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"toon",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"};function _(M){return c.add(M),M===0?"uv":`uv${M}`}function m(M,v,P,U,O){const G=U.fog,Y=O.geometry,H=M.isMeshStandardMaterial?U.environment:null,q=(M.isMeshStandardMaterial?t:e).get(M.envMap||H),k=q&&q.mapping===nl?q.image.height:null,ne=g[M.type];M.precision!==null&&(f=i.getMaxPrecision(M.precision),f!==M.precision&&console.warn("THREE.WebGLProgram.getParameters:",M.precision,"not supported, using",f,"instead."));const D=Y.morphAttributes.position||Y.morphAttributes.normal||Y.morphAttributes.color,ue=D!==void 0?D.length:0;let Ie=0;Y.morphAttributes.position!==void 0&&(Ie=1),Y.morphAttributes.normal!==void 0&&(Ie=2),Y.morphAttributes.color!==void 0&&(Ie=3);let $e,K,te,_e;if(ne){const ge=mi[ne];$e=ge.vertexShader,K=ge.fragmentShader}else $e=M.vertexShader,K=M.fragmentShader,l.update(M),te=l.getVertexShaderID(M),_e=l.getFragmentShaderID(M);const ie=r.getRenderTarget(),Ee=r.state.buffers.depth.getReversed(),we=O.isInstancedMesh===!0,He=O.isBatchedMesh===!0,Ke=!!M.map,Fe=!!M.matcap,Ce=!!q,I=!!M.aoMap,mt=!!M.lightMap,Be=!!M.bumpMap,B=!!M.normalMap,Me=!!M.displacementMap,rt=!!M.emissiveMap,Te=!!M.metalnessMap,A=!!M.roughnessMap,S=M.anisotropy>0,z=M.clearcoat>0,Q=M.dispersion>0,J=M.iridescence>0,Z=M.sheen>0,fe=M.transmission>0,ae=S&&!!M.anisotropyMap,de=z&&!!M.clearcoatMap,Ge=z&&!!M.clearcoatNormalMap,re=z&&!!M.clearcoatRoughnessMap,se=J&&!!M.iridescenceMap,Le=J&&!!M.iridescenceThicknessMap,Pe=Z&&!!M.sheenColorMap,ve=Z&&!!M.sheenRoughnessMap,We=!!M.specularMap,Oe=!!M.specularColorMap,ot=!!M.specularIntensityMap,L=fe&&!!M.transmissionMap,ce=fe&&!!M.thicknessMap,$=!!M.gradientMap,j=!!M.alphaMap,le=M.alphaTest>0,he=!!M.alphaHash,ze=!!M.extensions;let lt=ir;M.toneMapped&&(ie===null||ie.isXRRenderTarget===!0)&&(lt=r.toneMapping);const Ct={shaderID:ne,shaderType:M.type,shaderName:M.name,vertexShader:$e,fragmentShader:K,defines:M.defines,customVertexShaderID:te,customFragmentShaderID:_e,isRawShaderMaterial:M.isRawShaderMaterial===!0,glslVersion:M.glslVersion,precision:f,batching:He,batchingColor:He&&O._colorsTexture!==null,instancing:we,instancingColor:we&&O.instanceColor!==null,instancingMorph:we&&O.morphTexture!==null,supportsVertexTextures:d,outputColorSpace:ie===null?r.outputColorSpace:ie.isXRRenderTarget===!0?ie.texture.colorSpace:Ls,alphaToCoverage:!!M.alphaToCoverage,map:Ke,matcap:Fe,envMap:Ce,envMapMode:Ce&&q.mapping,envMapCubeUVHeight:k,aoMap:I,lightMap:mt,bumpMap:Be,normalMap:B,displacementMap:d&&Me,emissiveMap:rt,normalMapObjectSpace:B&&M.normalMapType===_m,normalMapTangentSpace:B&&M.normalMapType===mm,metalnessMap:Te,roughnessMap:A,anisotropy:S,anisotropyMap:ae,clearcoat:z,clearcoatMap:de,clearcoatNormalMap:Ge,clearcoatRoughnessMap:re,dispersion:Q,iridescence:J,iridescenceMap:se,iridescenceThicknessMap:Le,sheen:Z,sheenColorMap:Pe,sheenRoughnessMap:ve,specularMap:We,specularColorMap:Oe,specularIntensityMap:ot,transmission:fe,transmissionMap:L,thicknessMap:ce,gradientMap:$,opaque:M.transparent===!1&&M.blending===vs&&M.alphaToCoverage===!1,alphaMap:j,alphaTest:le,alphaHash:he,combine:M.combine,mapUv:Ke&&_(M.map.channel),aoMapUv:I&&_(M.aoMap.channel),lightMapUv:mt&&_(M.lightMap.channel),bumpMapUv:Be&&_(M.bumpMap.channel),normalMapUv:B&&_(M.normalMap.channel),displacementMapUv:Me&&_(M.displacementMap.channel),emissiveMapUv:rt&&_(M.emissiveMap.channel),metalnessMapUv:Te&&_(M.metalnessMap.channel),roughnessMapUv:A&&_(M.roughnessMap.channel),anisotropyMapUv:ae&&_(M.anisotropyMap.channel),clearcoatMapUv:de&&_(M.clearcoatMap.channel),clearcoatNormalMapUv:Ge&&_(M.clearcoatNormalMap.channel),clearcoatRoughnessMapUv:re&&_(M.clearcoatRoughnessMap.channel),iridescenceMapUv:se&&_(M.iridescenceMap.channel),iridescenceThicknessMapUv:Le&&_(M.iridescenceThicknessMap.channel),sheenColorMapUv:Pe&&_(M.sheenColorMap.channel),sheenRoughnessMapUv:ve&&_(M.sheenRoughnessMap.channel),specularMapUv:We&&_(M.specularMap.channel),specularColorMapUv:Oe&&_(M.specularColorMap.channel),specularIntensityMapUv:ot&&_(M.specularIntensityMap.channel),transmissionMapUv:L&&_(M.transmissionMap.channel),thicknessMapUv:ce&&_(M.thicknessMap.channel),alphaMapUv:j&&_(M.alphaMap.channel),vertexTangents:!!Y.attributes.tangent&&(B||S),vertexColors:M.vertexColors,vertexAlphas:M.vertexColors===!0&&!!Y.attributes.color&&Y.attributes.color.itemSize===4,pointsUvs:O.isPoints===!0&&!!Y.attributes.uv&&(Ke||j),fog:!!G,useFog:M.fog===!0,fogExp2:!!G&&G.isFogExp2,flatShading:M.flatShading===!0,sizeAttenuation:M.sizeAttenuation===!0,logarithmicDepthBuffer:h,reverseDepthBuffer:Ee,skinning:O.isSkinnedMesh===!0,morphTargets:Y.morphAttributes.position!==void 0,morphNormals:Y.morphAttributes.normal!==void 0,morphColors:Y.morphAttributes.color!==void 0,morphTargetsCount:ue,morphTextureStride:Ie,numDirLights:v.directional.length,numPointLights:v.point.length,numSpotLights:v.spot.length,numSpotLightMaps:v.spotLightMap.length,numRectAreaLights:v.rectArea.length,numHemiLights:v.hemi.length,numDirLightShadows:v.directionalShadowMap.length,numPointLightShadows:v.pointShadowMap.length,numSpotLightShadows:v.spotShadowMap.length,numSpotLightShadowsWithMaps:v.numSpotLightShadowsWithMaps,numLightProbes:v.numLightProbes,numClippingPlanes:a.numPlanes,numClipIntersection:a.numIntersection,dithering:M.dithering,shadowMapEnabled:r.shadowMap.enabled&&P.length>0,shadowMapType:r.shadowMap.type,toneMapping:lt,decodeVideoTexture:Ke&&M.map.isVideoTexture===!0&&ut.getTransfer(M.map.colorSpace)===pt,decodeVideoTextureEmissive:rt&&M.emissiveMap.isVideoTexture===!0&&ut.getTransfer(M.emissiveMap.colorSpace)===pt,premultipliedAlpha:M.premultipliedAlpha,doubleSided:M.side===Pi,flipSided:M.side===Tn,useDepthPacking:M.depthPacking>=0,depthPacking:M.depthPacking||0,index0AttributeName:M.index0AttributeName,extensionClipCullDistance:ze&&M.extensions.clipCullDistance===!0&&n.has("WEBGL_clip_cull_distance"),extensionMultiDraw:(ze&&M.extensions.multiDraw===!0||He)&&n.has("WEBGL_multi_draw"),rendererExtensionParallelShaderCompile:n.has("KHR_parallel_shader_compile"),customProgramCacheKey:M.customProgramCacheKey()};return Ct.vertexUv1s=c.has(1),Ct.vertexUv2s=c.has(2),Ct.vertexUv3s=c.has(3),c.clear(),Ct}function p(M){const v=[];if(M.shaderID?v.push(M.shaderID):(v.push(M.customVertexShaderID),v.push(M.customFragmentShaderID)),M.defines!==void 0)for(const P in M.defines)v.push(P),v.push(M.defines[P]);return M.isRawShaderMaterial===!1&&(T(v,M),E(v,M),v.push(r.outputColorSpace)),v.push(M.customProgramCacheKey),v.join()}function T(M,v){M.push(v.precision),M.push(v.outputColorSpace),M.push(v.envMapMode),M.push(v.envMapCubeUVHeight),M.push(v.mapUv),M.push(v.alphaMapUv),M.push(v.lightMapUv),M.push(v.aoMapUv),M.push(v.bumpMapUv),M.push(v.normalMapUv),M.push(v.displacementMapUv),M.push(v.emissiveMapUv),M.push(v.metalnessMapUv),M.push(v.roughnessMapUv),M.push(v.anisotropyMapUv),M.push(v.clearcoatMapUv),M.push(v.clearcoatNormalMapUv),M.push(v.clearcoatRoughnessMapUv),M.push(v.iridescenceMapUv),M.push(v.iridescenceThicknessMapUv),M.push(v.sheenColorMapUv),M.push(v.sheenRoughnessMapUv),M.push(v.specularMapUv),M.push(v.specularColorMapUv),M.push(v.specularIntensityMapUv),M.push(v.transmissionMapUv),M.push(v.thicknessMapUv),M.push(v.combine),M.push(v.fogExp2),M.push(v.sizeAttenuation),M.push(v.morphTargetsCount),M.push(v.morphAttributeCount),M.push(v.numDirLights),M.push(v.numPointLights),M.push(v.numSpotLights),M.push(v.numSpotLightMaps),M.push(v.numHemiLights),M.push(v.numRectAreaLights),M.push(v.numDirLightShadows),M.push(v.numPointLightShadows),M.push(v.numSpotLightShadows),M.push(v.numSpotLightShadowsWithMaps),M.push(v.numLightProbes),M.push(v.shadowMapType),M.push(v.toneMapping),M.push(v.numClippingPlanes),M.push(v.numClipIntersection),M.push(v.depthPacking)}function E(M,v){o.disableAll(),v.supportsVertexTextures&&o.enable(0),v.instancing&&o.enable(1),v.instancingColor&&o.enable(2),v.instancingMorph&&o.enable(3),v.matcap&&o.enable(4),v.envMap&&o.enable(5),v.normalMapObjectSpace&&o.enable(6),v.normalMapTangentSpace&&o.enable(7),v.clearcoat&&o.enable(8),v.iridescence&&o.enable(9),v.alphaTest&&o.enable(10),v.vertexColors&&o.enable(11),v.vertexAlphas&&o.enable(12),v.vertexUv1s&&o.enable(13),v.vertexUv2s&&o.enable(14),v.vertexUv3s&&o.enable(15),v.vertexTangents&&o.enable(16),v.anisotropy&&o.enable(17),v.alphaHash&&o.enable(18),v.batching&&o.enable(19),v.dispersion&&o.enable(20),v.batchingColor&&o.enable(21),M.push(o.mask),o.disableAll(),v.fog&&o.enable(0),v.useFog&&o.enable(1),v.flatShading&&o.enable(2),v.logarithmicDepthBuffer&&o.enable(3),v.reverseDepthBuffer&&o.enable(4),v.skinning&&o.enable(5),v.morphTargets&&o.enable(6),v.morphNormals&&o.enable(7),v.morphColors&&o.enable(8),v.premultipliedAlpha&&o.enable(9),v.shadowMapEnabled&&o.enable(10),v.doubleSided&&o.enable(11),v.flipSided&&o.enable(12),v.useDepthPacking&&o.enable(13),v.dithering&&o.enable(14),v.transmission&&o.enable(15),v.sheen&&o.enable(16),v.opaque&&o.enable(17),v.pointsUvs&&o.enable(18),v.decodeVideoTexture&&o.enable(19),v.decodeVideoTextureEmissive&&o.enable(20),v.alphaToCoverage&&o.enable(21),M.push(o.mask)}function x(M){const v=g[M.type];let P;if(v){const U=mi[v];P=qm.clone(U.uniforms)}else P=M.uniforms;return P}function R(M,v){let P;for(let U=0,O=u.length;U<O;U++){const G=u[U];if(G.cacheKey===v){P=G,++P.usedTimes;break}}return P===void 0&&(P=new mx(r,v,M,s),u.push(P)),P}function w(M){if(--M.usedTimes===0){const v=u.indexOf(M);u[v]=u[u.length-1],u.pop(),M.destroy()}}function b(M){l.remove(M)}function C(){l.dispose()}return{getParameters:m,getProgramCacheKey:p,getUniforms:x,acquireProgram:R,releaseProgram:w,releaseShaderCache:b,programs:u,dispose:C}}function Mx(){let r=new WeakMap;function e(a){return r.has(a)}function t(a){let o=r.get(a);return o===void 0&&(o={},r.set(a,o)),o}function n(a){r.delete(a)}function i(a,o,l){r.get(a)[o]=l}function s(){r=new WeakMap}return{has:e,get:t,remove:n,update:i,dispose:s}}function Sx(r,e){return r.groupOrder!==e.groupOrder?r.groupOrder-e.groupOrder:r.renderOrder!==e.renderOrder?r.renderOrder-e.renderOrder:r.material.id!==e.material.id?r.material.id-e.material.id:r.z!==e.z?r.z-e.z:r.id-e.id}function $f(r,e){return r.groupOrder!==e.groupOrder?r.groupOrder-e.groupOrder:r.renderOrder!==e.renderOrder?r.renderOrder-e.renderOrder:r.z!==e.z?e.z-r.z:r.id-e.id}function Kf(){const r=[];let e=0;const t=[],n=[],i=[];function s(){e=0,t.length=0,n.length=0,i.length=0}function a(h,d,f,g,_,m){let p=r[e];return p===void 0?(p={id:h.id,object:h,geometry:d,material:f,groupOrder:g,renderOrder:h.renderOrder,z:_,group:m},r[e]=p):(p.id=h.id,p.object=h,p.geometry=d,p.material=f,p.groupOrder=g,p.renderOrder=h.renderOrder,p.z=_,p.group=m),e++,p}function o(h,d,f,g,_,m){const p=a(h,d,f,g,_,m);f.transmission>0?n.push(p):f.transparent===!0?i.push(p):t.push(p)}function l(h,d,f,g,_,m){const p=a(h,d,f,g,_,m);f.transmission>0?n.unshift(p):f.transparent===!0?i.unshift(p):t.unshift(p)}function c(h,d){t.length>1&&t.sort(h||Sx),n.length>1&&n.sort(d||$f),i.length>1&&i.sort(d||$f)}function u(){for(let h=e,d=r.length;h<d;h++){const f=r[h];if(f.id===null)break;f.id=null,f.object=null,f.geometry=null,f.material=null,f.group=null}}return{opaque:t,transmissive:n,transparent:i,init:s,push:o,unshift:l,finish:u,sort:c}}function yx(){let r=new WeakMap;function e(n,i){const s=r.get(n);let a;return s===void 0?(a=new Kf,r.set(n,[a])):i>=s.length?(a=new Kf,s.push(a)):a=s[i],a}function t(){r=new WeakMap}return{get:e,dispose:t}}function Ex(){const r={};return{get:function(e){if(r[e.id]!==void 0)return r[e.id];let t;switch(e.type){case"DirectionalLight":t={direction:new X,color:new nt};break;case"SpotLight":t={position:new X,direction:new X,color:new nt,distance:0,coneCos:0,penumbraCos:0,decay:0};break;case"PointLight":t={position:new X,color:new nt,distance:0,decay:0};break;case"HemisphereLight":t={direction:new X,skyColor:new nt,groundColor:new nt};break;case"RectAreaLight":t={color:new nt,position:new X,halfWidth:new X,halfHeight:new X};break}return r[e.id]=t,t}}}function Tx(){const r={};return{get:function(e){if(r[e.id]!==void 0)return r[e.id];let t;switch(e.type){case"DirectionalLight":t={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Mt};break;case"SpotLight":t={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Mt};break;case"PointLight":t={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Mt,shadowCameraNear:1,shadowCameraFar:1e3};break}return r[e.id]=t,t}}}let bx=0;function Ax(r,e){return(e.castShadow?2:0)-(r.castShadow?2:0)+(e.map?1:0)-(r.map?1:0)}function wx(r){const e=new Ex,t=Tx(),n={version:0,hash:{directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,numDirectionalShadows:-1,numPointShadows:-1,numSpotShadows:-1,numSpotMaps:-1,numLightProbes:-1},ambient:[0,0,0],probe:[],directional:[],directionalShadow:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotLightMap:[],spotShadow:[],spotShadowMap:[],spotLightMatrix:[],rectArea:[],rectAreaLTC1:null,rectAreaLTC2:null,point:[],pointShadow:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[],numSpotLightShadowsWithMaps:0,numLightProbes:0};for(let c=0;c<9;c++)n.probe.push(new X);const i=new X,s=new Lt,a=new Lt;function o(c){let u=0,h=0,d=0;for(let M=0;M<9;M++)n.probe[M].set(0,0,0);let f=0,g=0,_=0,m=0,p=0,T=0,E=0,x=0,R=0,w=0,b=0;c.sort(Ax);for(let M=0,v=c.length;M<v;M++){const P=c[M],U=P.color,O=P.intensity,G=P.distance,Y=P.shadow&&P.shadow.map?P.shadow.map.texture:null;if(P.isAmbientLight)u+=U.r*O,h+=U.g*O,d+=U.b*O;else if(P.isLightProbe){for(let H=0;H<9;H++)n.probe[H].addScaledVector(P.sh.coefficients[H],O);b++}else if(P.isDirectionalLight){const H=e.get(P);if(H.color.copy(P.color).multiplyScalar(P.intensity),P.castShadow){const q=P.shadow,k=t.get(P);k.shadowIntensity=q.intensity,k.shadowBias=q.bias,k.shadowNormalBias=q.normalBias,k.shadowRadius=q.radius,k.shadowMapSize=q.mapSize,n.directionalShadow[f]=k,n.directionalShadowMap[f]=Y,n.directionalShadowMatrix[f]=P.shadow.matrix,T++}n.directional[f]=H,f++}else if(P.isSpotLight){const H=e.get(P);H.position.setFromMatrixPosition(P.matrixWorld),H.color.copy(U).multiplyScalar(O),H.distance=G,H.coneCos=Math.cos(P.angle),H.penumbraCos=Math.cos(P.angle*(1-P.penumbra)),H.decay=P.decay,n.spot[_]=H;const q=P.shadow;if(P.map&&(n.spotLightMap[R]=P.map,R++,q.updateMatrices(P),P.castShadow&&w++),n.spotLightMatrix[_]=q.matrix,P.castShadow){const k=t.get(P);k.shadowIntensity=q.intensity,k.shadowBias=q.bias,k.shadowNormalBias=q.normalBias,k.shadowRadius=q.radius,k.shadowMapSize=q.mapSize,n.spotShadow[_]=k,n.spotShadowMap[_]=Y,x++}_++}else if(P.isRectAreaLight){const H=e.get(P);H.color.copy(U).multiplyScalar(O),H.halfWidth.set(P.width*.5,0,0),H.halfHeight.set(0,P.height*.5,0),n.rectArea[m]=H,m++}else if(P.isPointLight){const H=e.get(P);if(H.color.copy(P.color).multiplyScalar(P.intensity),H.distance=P.distance,H.decay=P.decay,P.castShadow){const q=P.shadow,k=t.get(P);k.shadowIntensity=q.intensity,k.shadowBias=q.bias,k.shadowNormalBias=q.normalBias,k.shadowRadius=q.radius,k.shadowMapSize=q.mapSize,k.shadowCameraNear=q.camera.near,k.shadowCameraFar=q.camera.far,n.pointShadow[g]=k,n.pointShadowMap[g]=Y,n.pointShadowMatrix[g]=P.shadow.matrix,E++}n.point[g]=H,g++}else if(P.isHemisphereLight){const H=e.get(P);H.skyColor.copy(P.color).multiplyScalar(O),H.groundColor.copy(P.groundColor).multiplyScalar(O),n.hemi[p]=H,p++}}m>0&&(r.has("OES_texture_float_linear")===!0?(n.rectAreaLTC1=me.LTC_FLOAT_1,n.rectAreaLTC2=me.LTC_FLOAT_2):(n.rectAreaLTC1=me.LTC_HALF_1,n.rectAreaLTC2=me.LTC_HALF_2)),n.ambient[0]=u,n.ambient[1]=h,n.ambient[2]=d;const C=n.hash;(C.directionalLength!==f||C.pointLength!==g||C.spotLength!==_||C.rectAreaLength!==m||C.hemiLength!==p||C.numDirectionalShadows!==T||C.numPointShadows!==E||C.numSpotShadows!==x||C.numSpotMaps!==R||C.numLightProbes!==b)&&(n.directional.length=f,n.spot.length=_,n.rectArea.length=m,n.point.length=g,n.hemi.length=p,n.directionalShadow.length=T,n.directionalShadowMap.length=T,n.pointShadow.length=E,n.pointShadowMap.length=E,n.spotShadow.length=x,n.spotShadowMap.length=x,n.directionalShadowMatrix.length=T,n.pointShadowMatrix.length=E,n.spotLightMatrix.length=x+R-w,n.spotLightMap.length=R,n.numSpotLightShadowsWithMaps=w,n.numLightProbes=b,C.directionalLength=f,C.pointLength=g,C.spotLength=_,C.rectAreaLength=m,C.hemiLength=p,C.numDirectionalShadows=T,C.numPointShadows=E,C.numSpotShadows=x,C.numSpotMaps=R,C.numLightProbes=b,n.version=bx++)}function l(c,u){let h=0,d=0,f=0,g=0,_=0;const m=u.matrixWorldInverse;for(let p=0,T=c.length;p<T;p++){const E=c[p];if(E.isDirectionalLight){const x=n.directional[h];x.direction.setFromMatrixPosition(E.matrixWorld),i.setFromMatrixPosition(E.target.matrixWorld),x.direction.sub(i),x.direction.transformDirection(m),h++}else if(E.isSpotLight){const x=n.spot[f];x.position.setFromMatrixPosition(E.matrixWorld),x.position.applyMatrix4(m),x.direction.setFromMatrixPosition(E.matrixWorld),i.setFromMatrixPosition(E.target.matrixWorld),x.direction.sub(i),x.direction.transformDirection(m),f++}else if(E.isRectAreaLight){const x=n.rectArea[g];x.position.setFromMatrixPosition(E.matrixWorld),x.position.applyMatrix4(m),a.identity(),s.copy(E.matrixWorld),s.premultiply(m),a.extractRotation(s),x.halfWidth.set(E.width*.5,0,0),x.halfHeight.set(0,E.height*.5,0),x.halfWidth.applyMatrix4(a),x.halfHeight.applyMatrix4(a),g++}else if(E.isPointLight){const x=n.point[d];x.position.setFromMatrixPosition(E.matrixWorld),x.position.applyMatrix4(m),d++}else if(E.isHemisphereLight){const x=n.hemi[_];x.direction.setFromMatrixPosition(E.matrixWorld),x.direction.transformDirection(m),_++}}}return{setup:o,setupView:l,state:n}}function Zf(r){const e=new wx(r),t=[],n=[];function i(u){c.camera=u,t.length=0,n.length=0}function s(u){t.push(u)}function a(u){n.push(u)}function o(){e.setup(t)}function l(u){e.setupView(t,u)}const c={lightsArray:t,shadowsArray:n,camera:null,lights:e,transmissionRenderTarget:{}};return{init:i,state:c,setupLights:o,setupLightsView:l,pushLight:s,pushShadow:a}}function Rx(r){let e=new WeakMap;function t(i,s=0){const a=e.get(i);let o;return a===void 0?(o=new Zf(r),e.set(i,[o])):s>=a.length?(o=new Zf(r),a.push(o)):o=a[s],o}function n(){e=new WeakMap}return{get:t,dispose:n}}const Cx=`void main() {
	gl_Position = vec4( position, 1.0 );
}`,Px=`uniform sampler2D shadow_pass;
uniform vec2 resolution;
uniform float radius;
#include <packing>
void main() {
	const float samples = float( VSM_SAMPLES );
	float mean = 0.0;
	float squared_mean = 0.0;
	float uvStride = samples <= 1.0 ? 0.0 : 2.0 / ( samples - 1.0 );
	float uvStart = samples <= 1.0 ? 0.0 : - 1.0;
	for ( float i = 0.0; i < samples; i ++ ) {
		float uvOffset = uvStart + i * uvStride;
		#ifdef HORIZONTAL_PASS
			vec2 distribution = unpackRGBATo2Half( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( uvOffset, 0.0 ) * radius ) / resolution ) );
			mean += distribution.x;
			squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;
		#else
			float depth = unpackRGBAToDepth( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( 0.0, uvOffset ) * radius ) / resolution ) );
			mean += depth;
			squared_mean += depth * depth;
		#endif
	}
	mean = mean / samples;
	squared_mean = squared_mean / samples;
	float std_dev = sqrt( squared_mean - mean * mean );
	gl_FragColor = pack2HalfToRGBA( vec2( mean, std_dev ) );
}`;function Dx(r,e,t){let n=new rd;const i=new Mt,s=new Mt,a=new Nt,o=new i_({depthPacking:pm}),l=new r_,c={},u=t.maxTextureSize,h={[or]:Tn,[Tn]:or,[Pi]:Pi},d=new lr({defines:{VSM_SAMPLES:8},uniforms:{shadow_pass:{value:null},resolution:{value:new Mt},radius:{value:4}},vertexShader:Cx,fragmentShader:Px}),f=d.clone();f.defines.HORIZONTAL_PASS=1;const g=new hi;g.setAttribute("position",new En(new Float32Array([-1,-1,.5,3,-1,.5,-1,3,.5]),3));const _=new Ui(g,d),m=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=Ih;let p=this.type;this.render=function(w,b,C){if(m.enabled===!1||m.autoUpdate===!1&&m.needsUpdate===!1||w.length===0)return;const M=r.getRenderTarget(),v=r.getActiveCubeFace(),P=r.getActiveMipmapLevel(),U=r.state;U.setBlending(nr),U.buffers.color.setClear(1,1,1,1),U.buffers.depth.setTest(!0),U.setScissorTest(!1);const O=p!==wi&&this.type===wi,G=p===wi&&this.type!==wi;for(let Y=0,H=w.length;Y<H;Y++){const q=w[Y],k=q.shadow;if(k===void 0){console.warn("THREE.WebGLShadowMap:",q,"has no shadow.");continue}if(k.autoUpdate===!1&&k.needsUpdate===!1)continue;i.copy(k.mapSize);const ne=k.getFrameExtents();if(i.multiply(ne),s.copy(k.mapSize),(i.x>u||i.y>u)&&(i.x>u&&(s.x=Math.floor(u/ne.x),i.x=s.x*ne.x,k.mapSize.x=s.x),i.y>u&&(s.y=Math.floor(u/ne.y),i.y=s.y*ne.y,k.mapSize.y=s.y)),k.map===null||O===!0||G===!0){const ue=this.type!==wi?{minFilter:fi,magFilter:fi}:{};k.map!==null&&k.map.dispose(),k.map=new Vr(i.x,i.y,ue),k.map.texture.name=q.name+".shadowMap",k.camera.updateProjectionMatrix()}r.setRenderTarget(k.map),r.clear();const D=k.getViewportCount();for(let ue=0;ue<D;ue++){const Ie=k.getViewport(ue);a.set(s.x*Ie.x,s.y*Ie.y,s.x*Ie.z,s.y*Ie.w),U.viewport(a),k.updateMatrices(q,ue),n=k.getFrustum(),x(b,C,k.camera,q,this.type)}k.isPointLightShadow!==!0&&this.type===wi&&T(k,C),k.needsUpdate=!1}p=this.type,m.needsUpdate=!1,r.setRenderTarget(M,v,P)};function T(w,b){const C=e.update(_);d.defines.VSM_SAMPLES!==w.blurSamples&&(d.defines.VSM_SAMPLES=w.blurSamples,f.defines.VSM_SAMPLES=w.blurSamples,d.needsUpdate=!0,f.needsUpdate=!0),w.mapPass===null&&(w.mapPass=new Vr(i.x,i.y)),d.uniforms.shadow_pass.value=w.map.texture,d.uniforms.resolution.value=w.mapSize,d.uniforms.radius.value=w.radius,r.setRenderTarget(w.mapPass),r.clear(),r.renderBufferDirect(b,null,C,d,_,null),f.uniforms.shadow_pass.value=w.mapPass.texture,f.uniforms.resolution.value=w.mapSize,f.uniforms.radius.value=w.radius,r.setRenderTarget(w.map),r.clear(),r.renderBufferDirect(b,null,C,f,_,null)}function E(w,b,C,M){let v=null;const P=C.isPointLight===!0?w.customDistanceMaterial:w.customDepthMaterial;if(P!==void 0)v=P;else if(v=C.isPointLight===!0?l:o,r.localClippingEnabled&&b.clipShadows===!0&&Array.isArray(b.clippingPlanes)&&b.clippingPlanes.length!==0||b.displacementMap&&b.displacementScale!==0||b.alphaMap&&b.alphaTest>0||b.map&&b.alphaTest>0){const U=v.uuid,O=b.uuid;let G=c[U];G===void 0&&(G={},c[U]=G);let Y=G[O];Y===void 0&&(Y=v.clone(),G[O]=Y,b.addEventListener("dispose",R)),v=Y}if(v.visible=b.visible,v.wireframe=b.wireframe,M===wi?v.side=b.shadowSide!==null?b.shadowSide:b.side:v.side=b.shadowSide!==null?b.shadowSide:h[b.side],v.alphaMap=b.alphaMap,v.alphaTest=b.alphaTest,v.map=b.map,v.clipShadows=b.clipShadows,v.clippingPlanes=b.clippingPlanes,v.clipIntersection=b.clipIntersection,v.displacementMap=b.displacementMap,v.displacementScale=b.displacementScale,v.displacementBias=b.displacementBias,v.wireframeLinewidth=b.wireframeLinewidth,v.linewidth=b.linewidth,C.isPointLight===!0&&v.isMeshDistanceMaterial===!0){const U=r.properties.get(v);U.light=C}return v}function x(w,b,C,M,v){if(w.visible===!1)return;if(w.layers.test(b.layers)&&(w.isMesh||w.isLine||w.isPoints)&&(w.castShadow||w.receiveShadow&&v===wi)&&(!w.frustumCulled||n.intersectsObject(w))){w.modelViewMatrix.multiplyMatrices(C.matrixWorldInverse,w.matrixWorld);const O=e.update(w),G=w.material;if(Array.isArray(G)){const Y=O.groups;for(let H=0,q=Y.length;H<q;H++){const k=Y[H],ne=G[k.materialIndex];if(ne&&ne.visible){const D=E(w,ne,M,v);w.onBeforeShadow(r,w,b,C,O,D,k),r.renderBufferDirect(C,null,O,D,w,k),w.onAfterShadow(r,w,b,C,O,D,k)}}}else if(G.visible){const Y=E(w,G,M,v);w.onBeforeShadow(r,w,b,C,O,Y,null),r.renderBufferDirect(C,null,O,Y,w,null),w.onAfterShadow(r,w,b,C,O,Y,null)}}const U=w.children;for(let O=0,G=U.length;O<G;O++)x(U[O],b,C,M,v)}function R(w){w.target.removeEventListener("dispose",R);for(const C in c){const M=c[C],v=w.target.uuid;v in M&&(M[v].dispose(),delete M[v])}}}const Lx={[rc]:sc,[ac]:cc,[oc]:uc,[ws]:lc,[sc]:rc,[cc]:ac,[uc]:oc,[lc]:ws};function Ix(r,e){function t(){let L=!1;const ce=new Nt;let $=null;const j=new Nt(0,0,0,0);return{setMask:function(le){$!==le&&!L&&(r.colorMask(le,le,le,le),$=le)},setLocked:function(le){L=le},setClear:function(le,he,ze,lt,Ct){Ct===!0&&(le*=lt,he*=lt,ze*=lt),ce.set(le,he,ze,lt),j.equals(ce)===!1&&(r.clearColor(le,he,ze,lt),j.copy(ce))},reset:function(){L=!1,$=null,j.set(-1,0,0,0)}}}function n(){let L=!1,ce=!1,$=null,j=null,le=null;return{setReversed:function(he){if(ce!==he){const ze=e.get("EXT_clip_control");ce?ze.clipControlEXT(ze.LOWER_LEFT_EXT,ze.ZERO_TO_ONE_EXT):ze.clipControlEXT(ze.LOWER_LEFT_EXT,ze.NEGATIVE_ONE_TO_ONE_EXT);const lt=le;le=null,this.setClear(lt)}ce=he},getReversed:function(){return ce},setTest:function(he){he?ie(r.DEPTH_TEST):Ee(r.DEPTH_TEST)},setMask:function(he){$!==he&&!L&&(r.depthMask(he),$=he)},setFunc:function(he){if(ce&&(he=Lx[he]),j!==he){switch(he){case rc:r.depthFunc(r.NEVER);break;case sc:r.depthFunc(r.ALWAYS);break;case ac:r.depthFunc(r.LESS);break;case ws:r.depthFunc(r.LEQUAL);break;case oc:r.depthFunc(r.EQUAL);break;case lc:r.depthFunc(r.GEQUAL);break;case cc:r.depthFunc(r.GREATER);break;case uc:r.depthFunc(r.NOTEQUAL);break;default:r.depthFunc(r.LEQUAL)}j=he}},setLocked:function(he){L=he},setClear:function(he){le!==he&&(ce&&(he=1-he),r.clearDepth(he),le=he)},reset:function(){L=!1,$=null,j=null,le=null,ce=!1}}}function i(){let L=!1,ce=null,$=null,j=null,le=null,he=null,ze=null,lt=null,Ct=null;return{setTest:function(ge){L||(ge?ie(r.STENCIL_TEST):Ee(r.STENCIL_TEST))},setMask:function(ge){ce!==ge&&!L&&(r.stencilMask(ge),ce=ge)},setFunc:function(ge,be,Xe){($!==ge||j!==be||le!==Xe)&&(r.stencilFunc(ge,be,Xe),$=ge,j=be,le=Xe)},setOp:function(ge,be,Xe){(he!==ge||ze!==be||lt!==Xe)&&(r.stencilOp(ge,be,Xe),he=ge,ze=be,lt=Xe)},setLocked:function(ge){L=ge},setClear:function(ge){Ct!==ge&&(r.clearStencil(ge),Ct=ge)},reset:function(){L=!1,ce=null,$=null,j=null,le=null,he=null,ze=null,lt=null,Ct=null}}}const s=new t,a=new n,o=new i,l=new WeakMap,c=new WeakMap;let u={},h={},d=new WeakMap,f=[],g=null,_=!1,m=null,p=null,T=null,E=null,x=null,R=null,w=null,b=new nt(0,0,0),C=0,M=!1,v=null,P=null,U=null,O=null,G=null;const Y=r.getParameter(r.MAX_COMBINED_TEXTURE_IMAGE_UNITS);let H=!1,q=0;const k=r.getParameter(r.VERSION);k.indexOf("WebGL")!==-1?(q=parseFloat(/^WebGL (\d)/.exec(k)[1]),H=q>=1):k.indexOf("OpenGL ES")!==-1&&(q=parseFloat(/^OpenGL ES (\d)/.exec(k)[1]),H=q>=2);let ne=null,D={};const ue=r.getParameter(r.SCISSOR_BOX),Ie=r.getParameter(r.VIEWPORT),$e=new Nt().fromArray(ue),K=new Nt().fromArray(Ie);function te(L,ce,$,j){const le=new Uint8Array(4),he=r.createTexture();r.bindTexture(L,he),r.texParameteri(L,r.TEXTURE_MIN_FILTER,r.NEAREST),r.texParameteri(L,r.TEXTURE_MAG_FILTER,r.NEAREST);for(let ze=0;ze<$;ze++)L===r.TEXTURE_3D||L===r.TEXTURE_2D_ARRAY?r.texImage3D(ce,0,r.RGBA,1,1,j,0,r.RGBA,r.UNSIGNED_BYTE,le):r.texImage2D(ce+ze,0,r.RGBA,1,1,0,r.RGBA,r.UNSIGNED_BYTE,le);return he}const _e={};_e[r.TEXTURE_2D]=te(r.TEXTURE_2D,r.TEXTURE_2D,1),_e[r.TEXTURE_CUBE_MAP]=te(r.TEXTURE_CUBE_MAP,r.TEXTURE_CUBE_MAP_POSITIVE_X,6),_e[r.TEXTURE_2D_ARRAY]=te(r.TEXTURE_2D_ARRAY,r.TEXTURE_2D_ARRAY,1,1),_e[r.TEXTURE_3D]=te(r.TEXTURE_3D,r.TEXTURE_3D,1,1),s.setClear(0,0,0,1),a.setClear(1),o.setClear(0),ie(r.DEPTH_TEST),a.setFunc(ws),Be(!1),B(Ku),ie(r.CULL_FACE),I(nr);function ie(L){u[L]!==!0&&(r.enable(L),u[L]=!0)}function Ee(L){u[L]!==!1&&(r.disable(L),u[L]=!1)}function we(L,ce){return h[L]!==ce?(r.bindFramebuffer(L,ce),h[L]=ce,L===r.DRAW_FRAMEBUFFER&&(h[r.FRAMEBUFFER]=ce),L===r.FRAMEBUFFER&&(h[r.DRAW_FRAMEBUFFER]=ce),!0):!1}function He(L,ce){let $=f,j=!1;if(L){$=d.get(ce),$===void 0&&($=[],d.set(ce,$));const le=L.textures;if($.length!==le.length||$[0]!==r.COLOR_ATTACHMENT0){for(let he=0,ze=le.length;he<ze;he++)$[he]=r.COLOR_ATTACHMENT0+he;$.length=le.length,j=!0}}else $[0]!==r.BACK&&($[0]=r.BACK,j=!0);j&&r.drawBuffers($)}function Ke(L){return g!==L?(r.useProgram(L),g=L,!0):!1}const Fe={[Rr]:r.FUNC_ADD,[kp]:r.FUNC_SUBTRACT,[Hp]:r.FUNC_REVERSE_SUBTRACT};Fe[Vp]=r.MIN,Fe[Gp]=r.MAX;const Ce={[Wp]:r.ZERO,[Xp]:r.ONE,[qp]:r.SRC_COLOR,[nc]:r.SRC_ALPHA,[Jp]:r.SRC_ALPHA_SATURATE,[Zp]:r.DST_COLOR,[$p]:r.DST_ALPHA,[Yp]:r.ONE_MINUS_SRC_COLOR,[ic]:r.ONE_MINUS_SRC_ALPHA,[jp]:r.ONE_MINUS_DST_COLOR,[Kp]:r.ONE_MINUS_DST_ALPHA,[Qp]:r.CONSTANT_COLOR,[em]:r.ONE_MINUS_CONSTANT_COLOR,[tm]:r.CONSTANT_ALPHA,[nm]:r.ONE_MINUS_CONSTANT_ALPHA};function I(L,ce,$,j,le,he,ze,lt,Ct,ge){if(L===nr){_===!0&&(Ee(r.BLEND),_=!1);return}if(_===!1&&(ie(r.BLEND),_=!0),L!==zp){if(L!==m||ge!==M){if((p!==Rr||x!==Rr)&&(r.blendEquation(r.FUNC_ADD),p=Rr,x=Rr),ge)switch(L){case vs:r.blendFuncSeparate(r.ONE,r.ONE_MINUS_SRC_ALPHA,r.ONE,r.ONE_MINUS_SRC_ALPHA);break;case zo:r.blendFunc(r.ONE,r.ONE);break;case Zu:r.blendFuncSeparate(r.ZERO,r.ONE_MINUS_SRC_COLOR,r.ZERO,r.ONE);break;case ju:r.blendFuncSeparate(r.ZERO,r.SRC_COLOR,r.ZERO,r.SRC_ALPHA);break;default:console.error("THREE.WebGLState: Invalid blending: ",L);break}else switch(L){case vs:r.blendFuncSeparate(r.SRC_ALPHA,r.ONE_MINUS_SRC_ALPHA,r.ONE,r.ONE_MINUS_SRC_ALPHA);break;case zo:r.blendFunc(r.SRC_ALPHA,r.ONE);break;case Zu:r.blendFuncSeparate(r.ZERO,r.ONE_MINUS_SRC_COLOR,r.ZERO,r.ONE);break;case ju:r.blendFunc(r.ZERO,r.SRC_COLOR);break;default:console.error("THREE.WebGLState: Invalid blending: ",L);break}T=null,E=null,R=null,w=null,b.set(0,0,0),C=0,m=L,M=ge}return}le=le||ce,he=he||$,ze=ze||j,(ce!==p||le!==x)&&(r.blendEquationSeparate(Fe[ce],Fe[le]),p=ce,x=le),($!==T||j!==E||he!==R||ze!==w)&&(r.blendFuncSeparate(Ce[$],Ce[j],Ce[he],Ce[ze]),T=$,E=j,R=he,w=ze),(lt.equals(b)===!1||Ct!==C)&&(r.blendColor(lt.r,lt.g,lt.b,Ct),b.copy(lt),C=Ct),m=L,M=!1}function mt(L,ce){L.side===Pi?Ee(r.CULL_FACE):ie(r.CULL_FACE);let $=L.side===Tn;ce&&($=!$),Be($),L.blending===vs&&L.transparent===!1?I(nr):I(L.blending,L.blendEquation,L.blendSrc,L.blendDst,L.blendEquationAlpha,L.blendSrcAlpha,L.blendDstAlpha,L.blendColor,L.blendAlpha,L.premultipliedAlpha),a.setFunc(L.depthFunc),a.setTest(L.depthTest),a.setMask(L.depthWrite),s.setMask(L.colorWrite);const j=L.stencilWrite;o.setTest(j),j&&(o.setMask(L.stencilWriteMask),o.setFunc(L.stencilFunc,L.stencilRef,L.stencilFuncMask),o.setOp(L.stencilFail,L.stencilZFail,L.stencilZPass)),rt(L.polygonOffset,L.polygonOffsetFactor,L.polygonOffsetUnits),L.alphaToCoverage===!0?ie(r.SAMPLE_ALPHA_TO_COVERAGE):Ee(r.SAMPLE_ALPHA_TO_COVERAGE)}function Be(L){v!==L&&(L?r.frontFace(r.CW):r.frontFace(r.CCW),v=L)}function B(L){L!==Fp?(ie(r.CULL_FACE),L!==P&&(L===Ku?r.cullFace(r.BACK):L===Op?r.cullFace(r.FRONT):r.cullFace(r.FRONT_AND_BACK))):Ee(r.CULL_FACE),P=L}function Me(L){L!==U&&(H&&r.lineWidth(L),U=L)}function rt(L,ce,$){L?(ie(r.POLYGON_OFFSET_FILL),(O!==ce||G!==$)&&(r.polygonOffset(ce,$),O=ce,G=$)):Ee(r.POLYGON_OFFSET_FILL)}function Te(L){L?ie(r.SCISSOR_TEST):Ee(r.SCISSOR_TEST)}function A(L){L===void 0&&(L=r.TEXTURE0+Y-1),ne!==L&&(r.activeTexture(L),ne=L)}function S(L,ce,$){$===void 0&&(ne===null?$=r.TEXTURE0+Y-1:$=ne);let j=D[$];j===void 0&&(j={type:void 0,texture:void 0},D[$]=j),(j.type!==L||j.texture!==ce)&&(ne!==$&&(r.activeTexture($),ne=$),r.bindTexture(L,ce||_e[L]),j.type=L,j.texture=ce)}function z(){const L=D[ne];L!==void 0&&L.type!==void 0&&(r.bindTexture(L.type,null),L.type=void 0,L.texture=void 0)}function Q(){try{r.compressedTexImage2D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function J(){try{r.compressedTexImage3D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function Z(){try{r.texSubImage2D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function fe(){try{r.texSubImage3D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function ae(){try{r.compressedTexSubImage2D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function de(){try{r.compressedTexSubImage3D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function Ge(){try{r.texStorage2D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function re(){try{r.texStorage3D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function se(){try{r.texImage2D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function Le(){try{r.texImage3D.apply(r,arguments)}catch(L){console.error("THREE.WebGLState:",L)}}function Pe(L){$e.equals(L)===!1&&(r.scissor(L.x,L.y,L.z,L.w),$e.copy(L))}function ve(L){K.equals(L)===!1&&(r.viewport(L.x,L.y,L.z,L.w),K.copy(L))}function We(L,ce){let $=c.get(ce);$===void 0&&($=new WeakMap,c.set(ce,$));let j=$.get(L);j===void 0&&(j=r.getUniformBlockIndex(ce,L.name),$.set(L,j))}function Oe(L,ce){const j=c.get(ce).get(L);l.get(ce)!==j&&(r.uniformBlockBinding(ce,j,L.__bindingPointIndex),l.set(ce,j))}function ot(){r.disable(r.BLEND),r.disable(r.CULL_FACE),r.disable(r.DEPTH_TEST),r.disable(r.POLYGON_OFFSET_FILL),r.disable(r.SCISSOR_TEST),r.disable(r.STENCIL_TEST),r.disable(r.SAMPLE_ALPHA_TO_COVERAGE),r.blendEquation(r.FUNC_ADD),r.blendFunc(r.ONE,r.ZERO),r.blendFuncSeparate(r.ONE,r.ZERO,r.ONE,r.ZERO),r.blendColor(0,0,0,0),r.colorMask(!0,!0,!0,!0),r.clearColor(0,0,0,0),r.depthMask(!0),r.depthFunc(r.LESS),a.setReversed(!1),r.clearDepth(1),r.stencilMask(4294967295),r.stencilFunc(r.ALWAYS,0,4294967295),r.stencilOp(r.KEEP,r.KEEP,r.KEEP),r.clearStencil(0),r.cullFace(r.BACK),r.frontFace(r.CCW),r.polygonOffset(0,0),r.activeTexture(r.TEXTURE0),r.bindFramebuffer(r.FRAMEBUFFER,null),r.bindFramebuffer(r.DRAW_FRAMEBUFFER,null),r.bindFramebuffer(r.READ_FRAMEBUFFER,null),r.useProgram(null),r.lineWidth(1),r.scissor(0,0,r.canvas.width,r.canvas.height),r.viewport(0,0,r.canvas.width,r.canvas.height),u={},ne=null,D={},h={},d=new WeakMap,f=[],g=null,_=!1,m=null,p=null,T=null,E=null,x=null,R=null,w=null,b=new nt(0,0,0),C=0,M=!1,v=null,P=null,U=null,O=null,G=null,$e.set(0,0,r.canvas.width,r.canvas.height),K.set(0,0,r.canvas.width,r.canvas.height),s.reset(),a.reset(),o.reset()}return{buffers:{color:s,depth:a,stencil:o},enable:ie,disable:Ee,bindFramebuffer:we,drawBuffers:He,useProgram:Ke,setBlending:I,setMaterial:mt,setFlipSided:Be,setCullFace:B,setLineWidth:Me,setPolygonOffset:rt,setScissorTest:Te,activeTexture:A,bindTexture:S,unbindTexture:z,compressedTexImage2D:Q,compressedTexImage3D:J,texImage2D:se,texImage3D:Le,updateUBOMapping:We,uniformBlockBinding:Oe,texStorage2D:Ge,texStorage3D:re,texSubImage2D:Z,texSubImage3D:fe,compressedTexSubImage2D:ae,compressedTexSubImage3D:de,scissor:Pe,viewport:ve,reset:ot}}function Ux(r,e,t,n,i,s,a){const o=e.has("WEBGL_multisampled_render_to_texture")?e.get("WEBGL_multisampled_render_to_texture"):null,l=typeof navigator>"u"?!1:/OculusBrowser/g.test(navigator.userAgent),c=new Mt,u=new WeakMap;let h;const d=new WeakMap;let f=!1;try{f=typeof OffscreenCanvas<"u"&&new OffscreenCanvas(1,1).getContext("2d")!==null}catch{}function g(A,S){return f?new OffscreenCanvas(A,S):Vo("canvas")}function _(A,S,z){let Q=1;const J=Te(A);if((J.width>z||J.height>z)&&(Q=z/Math.max(J.width,J.height)),Q<1)if(typeof HTMLImageElement<"u"&&A instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&A instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&A instanceof ImageBitmap||typeof VideoFrame<"u"&&A instanceof VideoFrame){const Z=Math.floor(Q*J.width),fe=Math.floor(Q*J.height);h===void 0&&(h=g(Z,fe));const ae=S?g(Z,fe):h;return ae.width=Z,ae.height=fe,ae.getContext("2d").drawImage(A,0,0,Z,fe),console.warn("THREE.WebGLRenderer: Texture has been resized from ("+J.width+"x"+J.height+") to ("+Z+"x"+fe+")."),ae}else return"data"in A&&console.warn("THREE.WebGLRenderer: Image in DataTexture is too big ("+J.width+"x"+J.height+")."),A;return A}function m(A){return A.generateMipmaps}function p(A){r.generateMipmap(A)}function T(A){return A.isWebGLCubeRenderTarget?r.TEXTURE_CUBE_MAP:A.isWebGL3DRenderTarget?r.TEXTURE_3D:A.isWebGLArrayRenderTarget||A.isCompressedArrayTexture?r.TEXTURE_2D_ARRAY:r.TEXTURE_2D}function E(A,S,z,Q,J=!1){if(A!==null){if(r[A]!==void 0)return r[A];console.warn("THREE.WebGLRenderer: Attempt to use non-existing WebGL internal format '"+A+"'")}let Z=S;if(S===r.RED&&(z===r.FLOAT&&(Z=r.R32F),z===r.HALF_FLOAT&&(Z=r.R16F),z===r.UNSIGNED_BYTE&&(Z=r.R8)),S===r.RED_INTEGER&&(z===r.UNSIGNED_BYTE&&(Z=r.R8UI),z===r.UNSIGNED_SHORT&&(Z=r.R16UI),z===r.UNSIGNED_INT&&(Z=r.R32UI),z===r.BYTE&&(Z=r.R8I),z===r.SHORT&&(Z=r.R16I),z===r.INT&&(Z=r.R32I)),S===r.RG&&(z===r.FLOAT&&(Z=r.RG32F),z===r.HALF_FLOAT&&(Z=r.RG16F),z===r.UNSIGNED_BYTE&&(Z=r.RG8)),S===r.RG_INTEGER&&(z===r.UNSIGNED_BYTE&&(Z=r.RG8UI),z===r.UNSIGNED_SHORT&&(Z=r.RG16UI),z===r.UNSIGNED_INT&&(Z=r.RG32UI),z===r.BYTE&&(Z=r.RG8I),z===r.SHORT&&(Z=r.RG16I),z===r.INT&&(Z=r.RG32I)),S===r.RGB_INTEGER&&(z===r.UNSIGNED_BYTE&&(Z=r.RGB8UI),z===r.UNSIGNED_SHORT&&(Z=r.RGB16UI),z===r.UNSIGNED_INT&&(Z=r.RGB32UI),z===r.BYTE&&(Z=r.RGB8I),z===r.SHORT&&(Z=r.RGB16I),z===r.INT&&(Z=r.RGB32I)),S===r.RGBA_INTEGER&&(z===r.UNSIGNED_BYTE&&(Z=r.RGBA8UI),z===r.UNSIGNED_SHORT&&(Z=r.RGBA16UI),z===r.UNSIGNED_INT&&(Z=r.RGBA32UI),z===r.BYTE&&(Z=r.RGBA8I),z===r.SHORT&&(Z=r.RGBA16I),z===r.INT&&(Z=r.RGBA32I)),S===r.RGB&&z===r.UNSIGNED_INT_5_9_9_9_REV&&(Z=r.RGB9_E5),S===r.RGBA){const fe=J?ko:ut.getTransfer(Q);z===r.FLOAT&&(Z=r.RGBA32F),z===r.HALF_FLOAT&&(Z=r.RGBA16F),z===r.UNSIGNED_BYTE&&(Z=fe===pt?r.SRGB8_ALPHA8:r.RGBA8),z===r.UNSIGNED_SHORT_4_4_4_4&&(Z=r.RGBA4),z===r.UNSIGNED_SHORT_5_5_5_1&&(Z=r.RGB5_A1)}return(Z===r.R16F||Z===r.R32F||Z===r.RG16F||Z===r.RG32F||Z===r.RGBA16F||Z===r.RGBA32F)&&e.get("EXT_color_buffer_float"),Z}function x(A,S){let z;return A?S===null||S===Hr||S===Ps?z=r.DEPTH24_STENCIL8:S===Li?z=r.DEPTH32F_STENCIL8:S===Sa&&(z=r.DEPTH24_STENCIL8,console.warn("DepthTexture: 16 bit depth attachment is not supported with stencil. Using 24-bit attachment.")):S===null||S===Hr||S===Ps?z=r.DEPTH_COMPONENT24:S===Li?z=r.DEPTH_COMPONENT32F:S===Sa&&(z=r.DEPTH_COMPONENT16),z}function R(A,S){return m(A)===!0||A.isFramebufferTexture&&A.minFilter!==fi&&A.minFilter!==gi?Math.log2(Math.max(S.width,S.height))+1:A.mipmaps!==void 0&&A.mipmaps.length>0?A.mipmaps.length:A.isCompressedTexture&&Array.isArray(A.image)?S.mipmaps.length:1}function w(A){const S=A.target;S.removeEventListener("dispose",w),C(S),S.isVideoTexture&&u.delete(S)}function b(A){const S=A.target;S.removeEventListener("dispose",b),v(S)}function C(A){const S=n.get(A);if(S.__webglInit===void 0)return;const z=A.source,Q=d.get(z);if(Q){const J=Q[S.__cacheKey];J.usedTimes--,J.usedTimes===0&&M(A),Object.keys(Q).length===0&&d.delete(z)}n.remove(A)}function M(A){const S=n.get(A);r.deleteTexture(S.__webglTexture);const z=A.source,Q=d.get(z);delete Q[S.__cacheKey],a.memory.textures--}function v(A){const S=n.get(A);if(A.depthTexture&&(A.depthTexture.dispose(),n.remove(A.depthTexture)),A.isWebGLCubeRenderTarget)for(let Q=0;Q<6;Q++){if(Array.isArray(S.__webglFramebuffer[Q]))for(let J=0;J<S.__webglFramebuffer[Q].length;J++)r.deleteFramebuffer(S.__webglFramebuffer[Q][J]);else r.deleteFramebuffer(S.__webglFramebuffer[Q]);S.__webglDepthbuffer&&r.deleteRenderbuffer(S.__webglDepthbuffer[Q])}else{if(Array.isArray(S.__webglFramebuffer))for(let Q=0;Q<S.__webglFramebuffer.length;Q++)r.deleteFramebuffer(S.__webglFramebuffer[Q]);else r.deleteFramebuffer(S.__webglFramebuffer);if(S.__webglDepthbuffer&&r.deleteRenderbuffer(S.__webglDepthbuffer),S.__webglMultisampledFramebuffer&&r.deleteFramebuffer(S.__webglMultisampledFramebuffer),S.__webglColorRenderbuffer)for(let Q=0;Q<S.__webglColorRenderbuffer.length;Q++)S.__webglColorRenderbuffer[Q]&&r.deleteRenderbuffer(S.__webglColorRenderbuffer[Q]);S.__webglDepthRenderbuffer&&r.deleteRenderbuffer(S.__webglDepthRenderbuffer)}const z=A.textures;for(let Q=0,J=z.length;Q<J;Q++){const Z=n.get(z[Q]);Z.__webglTexture&&(r.deleteTexture(Z.__webglTexture),a.memory.textures--),n.remove(z[Q])}n.remove(A)}let P=0;function U(){P=0}function O(){const A=P;return A>=i.maxTextures&&console.warn("THREE.WebGLTextures: Trying to use "+A+" texture units while this GPU supports only "+i.maxTextures),P+=1,A}function G(A){const S=[];return S.push(A.wrapS),S.push(A.wrapT),S.push(A.wrapR||0),S.push(A.magFilter),S.push(A.minFilter),S.push(A.anisotropy),S.push(A.internalFormat),S.push(A.format),S.push(A.type),S.push(A.generateMipmaps),S.push(A.premultiplyAlpha),S.push(A.flipY),S.push(A.unpackAlignment),S.push(A.colorSpace),S.join()}function Y(A,S){const z=n.get(A);if(A.isVideoTexture&&Me(A),A.isRenderTargetTexture===!1&&A.version>0&&z.__version!==A.version){const Q=A.image;if(Q===null)console.warn("THREE.WebGLRenderer: Texture marked for update but no image data found.");else if(Q.complete===!1)console.warn("THREE.WebGLRenderer: Texture marked for update but image is incomplete");else{K(z,A,S);return}}t.bindTexture(r.TEXTURE_2D,z.__webglTexture,r.TEXTURE0+S)}function H(A,S){const z=n.get(A);if(A.version>0&&z.__version!==A.version){K(z,A,S);return}t.bindTexture(r.TEXTURE_2D_ARRAY,z.__webglTexture,r.TEXTURE0+S)}function q(A,S){const z=n.get(A);if(A.version>0&&z.__version!==A.version){K(z,A,S);return}t.bindTexture(r.TEXTURE_3D,z.__webglTexture,r.TEXTURE0+S)}function k(A,S){const z=n.get(A);if(A.version>0&&z.__version!==A.version){te(z,A,S);return}t.bindTexture(r.TEXTURE_CUBE_MAP,z.__webglTexture,r.TEXTURE0+S)}const ne={[dc]:r.REPEAT,[Pr]:r.CLAMP_TO_EDGE,[pc]:r.MIRRORED_REPEAT},D={[fi]:r.NEAREST,[hm]:r.NEAREST_MIPMAP_NEAREST,[Ba]:r.NEAREST_MIPMAP_LINEAR,[gi]:r.LINEAR,[ul]:r.LINEAR_MIPMAP_NEAREST,[Dr]:r.LINEAR_MIPMAP_LINEAR},ue={[gm]:r.NEVER,[Em]:r.ALWAYS,[vm]:r.LESS,[qh]:r.LEQUAL,[xm]:r.EQUAL,[ym]:r.GEQUAL,[Mm]:r.GREATER,[Sm]:r.NOTEQUAL};function Ie(A,S){if(S.type===Li&&e.has("OES_texture_float_linear")===!1&&(S.magFilter===gi||S.magFilter===ul||S.magFilter===Ba||S.magFilter===Dr||S.minFilter===gi||S.minFilter===ul||S.minFilter===Ba||S.minFilter===Dr)&&console.warn("THREE.WebGLRenderer: Unable to use linear filtering with floating point textures. OES_texture_float_linear not supported on this device."),r.texParameteri(A,r.TEXTURE_WRAP_S,ne[S.wrapS]),r.texParameteri(A,r.TEXTURE_WRAP_T,ne[S.wrapT]),(A===r.TEXTURE_3D||A===r.TEXTURE_2D_ARRAY)&&r.texParameteri(A,r.TEXTURE_WRAP_R,ne[S.wrapR]),r.texParameteri(A,r.TEXTURE_MAG_FILTER,D[S.magFilter]),r.texParameteri(A,r.TEXTURE_MIN_FILTER,D[S.minFilter]),S.compareFunction&&(r.texParameteri(A,r.TEXTURE_COMPARE_MODE,r.COMPARE_REF_TO_TEXTURE),r.texParameteri(A,r.TEXTURE_COMPARE_FUNC,ue[S.compareFunction])),e.has("EXT_texture_filter_anisotropic")===!0){if(S.magFilter===fi||S.minFilter!==Ba&&S.minFilter!==Dr||S.type===Li&&e.has("OES_texture_float_linear")===!1)return;if(S.anisotropy>1||n.get(S).__currentAnisotropy){const z=e.get("EXT_texture_filter_anisotropic");r.texParameterf(A,z.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(S.anisotropy,i.getMaxAnisotropy())),n.get(S).__currentAnisotropy=S.anisotropy}}}function $e(A,S){let z=!1;A.__webglInit===void 0&&(A.__webglInit=!0,S.addEventListener("dispose",w));const Q=S.source;let J=d.get(Q);J===void 0&&(J={},d.set(Q,J));const Z=G(S);if(Z!==A.__cacheKey){J[Z]===void 0&&(J[Z]={texture:r.createTexture(),usedTimes:0},a.memory.textures++,z=!0),J[Z].usedTimes++;const fe=J[A.__cacheKey];fe!==void 0&&(J[A.__cacheKey].usedTimes--,fe.usedTimes===0&&M(S)),A.__cacheKey=Z,A.__webglTexture=J[Z].texture}return z}function K(A,S,z){let Q=r.TEXTURE_2D;(S.isDataArrayTexture||S.isCompressedArrayTexture)&&(Q=r.TEXTURE_2D_ARRAY),S.isData3DTexture&&(Q=r.TEXTURE_3D);const J=$e(A,S),Z=S.source;t.bindTexture(Q,A.__webglTexture,r.TEXTURE0+z);const fe=n.get(Z);if(Z.version!==fe.__version||J===!0){t.activeTexture(r.TEXTURE0+z);const ae=ut.getPrimaries(ut.workingColorSpace),de=S.colorSpace===Zi?null:ut.getPrimaries(S.colorSpace),Ge=S.colorSpace===Zi||ae===de?r.NONE:r.BROWSER_DEFAULT_WEBGL;r.pixelStorei(r.UNPACK_FLIP_Y_WEBGL,S.flipY),r.pixelStorei(r.UNPACK_PREMULTIPLY_ALPHA_WEBGL,S.premultiplyAlpha),r.pixelStorei(r.UNPACK_ALIGNMENT,S.unpackAlignment),r.pixelStorei(r.UNPACK_COLORSPACE_CONVERSION_WEBGL,Ge);let re=_(S.image,!1,i.maxTextureSize);re=rt(S,re);const se=s.convert(S.format,S.colorSpace),Le=s.convert(S.type);let Pe=E(S.internalFormat,se,Le,S.colorSpace,S.isVideoTexture);Ie(Q,S);let ve;const We=S.mipmaps,Oe=S.isVideoTexture!==!0,ot=fe.__version===void 0||J===!0,L=Z.dataReady,ce=R(S,re);if(S.isDepthTexture)Pe=x(S.format===Ds,S.type),ot&&(Oe?t.texStorage2D(r.TEXTURE_2D,1,Pe,re.width,re.height):t.texImage2D(r.TEXTURE_2D,0,Pe,re.width,re.height,0,se,Le,null));else if(S.isDataTexture)if(We.length>0){Oe&&ot&&t.texStorage2D(r.TEXTURE_2D,ce,Pe,We[0].width,We[0].height);for(let $=0,j=We.length;$<j;$++)ve=We[$],Oe?L&&t.texSubImage2D(r.TEXTURE_2D,$,0,0,ve.width,ve.height,se,Le,ve.data):t.texImage2D(r.TEXTURE_2D,$,Pe,ve.width,ve.height,0,se,Le,ve.data);S.generateMipmaps=!1}else Oe?(ot&&t.texStorage2D(r.TEXTURE_2D,ce,Pe,re.width,re.height),L&&t.texSubImage2D(r.TEXTURE_2D,0,0,0,re.width,re.height,se,Le,re.data)):t.texImage2D(r.TEXTURE_2D,0,Pe,re.width,re.height,0,se,Le,re.data);else if(S.isCompressedTexture)if(S.isCompressedArrayTexture){Oe&&ot&&t.texStorage3D(r.TEXTURE_2D_ARRAY,ce,Pe,We[0].width,We[0].height,re.depth);for(let $=0,j=We.length;$<j;$++)if(ve=We[$],S.format!==ui)if(se!==null)if(Oe){if(L)if(S.layerUpdates.size>0){const le=Af(ve.width,ve.height,S.format,S.type);for(const he of S.layerUpdates){const ze=ve.data.subarray(he*le/ve.data.BYTES_PER_ELEMENT,(he+1)*le/ve.data.BYTES_PER_ELEMENT);t.compressedTexSubImage3D(r.TEXTURE_2D_ARRAY,$,0,0,he,ve.width,ve.height,1,se,ze)}S.clearLayerUpdates()}else t.compressedTexSubImage3D(r.TEXTURE_2D_ARRAY,$,0,0,0,ve.width,ve.height,re.depth,se,ve.data)}else t.compressedTexImage3D(r.TEXTURE_2D_ARRAY,$,Pe,ve.width,ve.height,re.depth,0,ve.data,0,0);else console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()");else Oe?L&&t.texSubImage3D(r.TEXTURE_2D_ARRAY,$,0,0,0,ve.width,ve.height,re.depth,se,Le,ve.data):t.texImage3D(r.TEXTURE_2D_ARRAY,$,Pe,ve.width,ve.height,re.depth,0,se,Le,ve.data)}else{Oe&&ot&&t.texStorage2D(r.TEXTURE_2D,ce,Pe,We[0].width,We[0].height);for(let $=0,j=We.length;$<j;$++)ve=We[$],S.format!==ui?se!==null?Oe?L&&t.compressedTexSubImage2D(r.TEXTURE_2D,$,0,0,ve.width,ve.height,se,ve.data):t.compressedTexImage2D(r.TEXTURE_2D,$,Pe,ve.width,ve.height,0,ve.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):Oe?L&&t.texSubImage2D(r.TEXTURE_2D,$,0,0,ve.width,ve.height,se,Le,ve.data):t.texImage2D(r.TEXTURE_2D,$,Pe,ve.width,ve.height,0,se,Le,ve.data)}else if(S.isDataArrayTexture)if(Oe){if(ot&&t.texStorage3D(r.TEXTURE_2D_ARRAY,ce,Pe,re.width,re.height,re.depth),L)if(S.layerUpdates.size>0){const $=Af(re.width,re.height,S.format,S.type);for(const j of S.layerUpdates){const le=re.data.subarray(j*$/re.data.BYTES_PER_ELEMENT,(j+1)*$/re.data.BYTES_PER_ELEMENT);t.texSubImage3D(r.TEXTURE_2D_ARRAY,0,0,0,j,re.width,re.height,1,se,Le,le)}S.clearLayerUpdates()}else t.texSubImage3D(r.TEXTURE_2D_ARRAY,0,0,0,0,re.width,re.height,re.depth,se,Le,re.data)}else t.texImage3D(r.TEXTURE_2D_ARRAY,0,Pe,re.width,re.height,re.depth,0,se,Le,re.data);else if(S.isData3DTexture)Oe?(ot&&t.texStorage3D(r.TEXTURE_3D,ce,Pe,re.width,re.height,re.depth),L&&t.texSubImage3D(r.TEXTURE_3D,0,0,0,0,re.width,re.height,re.depth,se,Le,re.data)):t.texImage3D(r.TEXTURE_3D,0,Pe,re.width,re.height,re.depth,0,se,Le,re.data);else if(S.isFramebufferTexture){if(ot)if(Oe)t.texStorage2D(r.TEXTURE_2D,ce,Pe,re.width,re.height);else{let $=re.width,j=re.height;for(let le=0;le<ce;le++)t.texImage2D(r.TEXTURE_2D,le,Pe,$,j,0,se,Le,null),$>>=1,j>>=1}}else if(We.length>0){if(Oe&&ot){const $=Te(We[0]);t.texStorage2D(r.TEXTURE_2D,ce,Pe,$.width,$.height)}for(let $=0,j=We.length;$<j;$++)ve=We[$],Oe?L&&t.texSubImage2D(r.TEXTURE_2D,$,0,0,se,Le,ve):t.texImage2D(r.TEXTURE_2D,$,Pe,se,Le,ve);S.generateMipmaps=!1}else if(Oe){if(ot){const $=Te(re);t.texStorage2D(r.TEXTURE_2D,ce,Pe,$.width,$.height)}L&&t.texSubImage2D(r.TEXTURE_2D,0,0,0,se,Le,re)}else t.texImage2D(r.TEXTURE_2D,0,Pe,se,Le,re);m(S)&&p(Q),fe.__version=Z.version,S.onUpdate&&S.onUpdate(S)}A.__version=S.version}function te(A,S,z){if(S.image.length!==6)return;const Q=$e(A,S),J=S.source;t.bindTexture(r.TEXTURE_CUBE_MAP,A.__webglTexture,r.TEXTURE0+z);const Z=n.get(J);if(J.version!==Z.__version||Q===!0){t.activeTexture(r.TEXTURE0+z);const fe=ut.getPrimaries(ut.workingColorSpace),ae=S.colorSpace===Zi?null:ut.getPrimaries(S.colorSpace),de=S.colorSpace===Zi||fe===ae?r.NONE:r.BROWSER_DEFAULT_WEBGL;r.pixelStorei(r.UNPACK_FLIP_Y_WEBGL,S.flipY),r.pixelStorei(r.UNPACK_PREMULTIPLY_ALPHA_WEBGL,S.premultiplyAlpha),r.pixelStorei(r.UNPACK_ALIGNMENT,S.unpackAlignment),r.pixelStorei(r.UNPACK_COLORSPACE_CONVERSION_WEBGL,de);const Ge=S.isCompressedTexture||S.image[0].isCompressedTexture,re=S.image[0]&&S.image[0].isDataTexture,se=[];for(let j=0;j<6;j++)!Ge&&!re?se[j]=_(S.image[j],!0,i.maxCubemapSize):se[j]=re?S.image[j].image:S.image[j],se[j]=rt(S,se[j]);const Le=se[0],Pe=s.convert(S.format,S.colorSpace),ve=s.convert(S.type),We=E(S.internalFormat,Pe,ve,S.colorSpace),Oe=S.isVideoTexture!==!0,ot=Z.__version===void 0||Q===!0,L=J.dataReady;let ce=R(S,Le);Ie(r.TEXTURE_CUBE_MAP,S);let $;if(Ge){Oe&&ot&&t.texStorage2D(r.TEXTURE_CUBE_MAP,ce,We,Le.width,Le.height);for(let j=0;j<6;j++){$=se[j].mipmaps;for(let le=0;le<$.length;le++){const he=$[le];S.format!==ui?Pe!==null?Oe?L&&t.compressedTexSubImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le,0,0,he.width,he.height,Pe,he.data):t.compressedTexImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le,We,he.width,he.height,0,he.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):Oe?L&&t.texSubImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le,0,0,he.width,he.height,Pe,ve,he.data):t.texImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le,We,he.width,he.height,0,Pe,ve,he.data)}}}else{if($=S.mipmaps,Oe&&ot){$.length>0&&ce++;const j=Te(se[0]);t.texStorage2D(r.TEXTURE_CUBE_MAP,ce,We,j.width,j.height)}for(let j=0;j<6;j++)if(re){Oe?L&&t.texSubImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,0,0,se[j].width,se[j].height,Pe,ve,se[j].data):t.texImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,We,se[j].width,se[j].height,0,Pe,ve,se[j].data);for(let le=0;le<$.length;le++){const ze=$[le].image[j].image;Oe?L&&t.texSubImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le+1,0,0,ze.width,ze.height,Pe,ve,ze.data):t.texImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le+1,We,ze.width,ze.height,0,Pe,ve,ze.data)}}else{Oe?L&&t.texSubImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,0,0,Pe,ve,se[j]):t.texImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,0,We,Pe,ve,se[j]);for(let le=0;le<$.length;le++){const he=$[le];Oe?L&&t.texSubImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le+1,0,0,Pe,ve,he.image[j]):t.texImage2D(r.TEXTURE_CUBE_MAP_POSITIVE_X+j,le+1,We,Pe,ve,he.image[j])}}}m(S)&&p(r.TEXTURE_CUBE_MAP),Z.__version=J.version,S.onUpdate&&S.onUpdate(S)}A.__version=S.version}function _e(A,S,z,Q,J,Z){const fe=s.convert(z.format,z.colorSpace),ae=s.convert(z.type),de=E(z.internalFormat,fe,ae,z.colorSpace),Ge=n.get(S),re=n.get(z);if(re.__renderTarget=S,!Ge.__hasExternalTextures){const se=Math.max(1,S.width>>Z),Le=Math.max(1,S.height>>Z);J===r.TEXTURE_3D||J===r.TEXTURE_2D_ARRAY?t.texImage3D(J,Z,de,se,Le,S.depth,0,fe,ae,null):t.texImage2D(J,Z,de,se,Le,0,fe,ae,null)}t.bindFramebuffer(r.FRAMEBUFFER,A),B(S)?o.framebufferTexture2DMultisampleEXT(r.FRAMEBUFFER,Q,J,re.__webglTexture,0,Be(S)):(J===r.TEXTURE_2D||J>=r.TEXTURE_CUBE_MAP_POSITIVE_X&&J<=r.TEXTURE_CUBE_MAP_NEGATIVE_Z)&&r.framebufferTexture2D(r.FRAMEBUFFER,Q,J,re.__webglTexture,Z),t.bindFramebuffer(r.FRAMEBUFFER,null)}function ie(A,S,z){if(r.bindRenderbuffer(r.RENDERBUFFER,A),S.depthBuffer){const Q=S.depthTexture,J=Q&&Q.isDepthTexture?Q.type:null,Z=x(S.stencilBuffer,J),fe=S.stencilBuffer?r.DEPTH_STENCIL_ATTACHMENT:r.DEPTH_ATTACHMENT,ae=Be(S);B(S)?o.renderbufferStorageMultisampleEXT(r.RENDERBUFFER,ae,Z,S.width,S.height):z?r.renderbufferStorageMultisample(r.RENDERBUFFER,ae,Z,S.width,S.height):r.renderbufferStorage(r.RENDERBUFFER,Z,S.width,S.height),r.framebufferRenderbuffer(r.FRAMEBUFFER,fe,r.RENDERBUFFER,A)}else{const Q=S.textures;for(let J=0;J<Q.length;J++){const Z=Q[J],fe=s.convert(Z.format,Z.colorSpace),ae=s.convert(Z.type),de=E(Z.internalFormat,fe,ae,Z.colorSpace),Ge=Be(S);z&&B(S)===!1?r.renderbufferStorageMultisample(r.RENDERBUFFER,Ge,de,S.width,S.height):B(S)?o.renderbufferStorageMultisampleEXT(r.RENDERBUFFER,Ge,de,S.width,S.height):r.renderbufferStorage(r.RENDERBUFFER,de,S.width,S.height)}}r.bindRenderbuffer(r.RENDERBUFFER,null)}function Ee(A,S){if(S&&S.isWebGLCubeRenderTarget)throw new Error("Depth Texture with cube render targets is not supported");if(t.bindFramebuffer(r.FRAMEBUFFER,A),!(S.depthTexture&&S.depthTexture.isDepthTexture))throw new Error("renderTarget.depthTexture must be an instance of THREE.DepthTexture");const Q=n.get(S.depthTexture);Q.__renderTarget=S,(!Q.__webglTexture||S.depthTexture.image.width!==S.width||S.depthTexture.image.height!==S.height)&&(S.depthTexture.image.width=S.width,S.depthTexture.image.height=S.height,S.depthTexture.needsUpdate=!0),Y(S.depthTexture,0);const J=Q.__webglTexture,Z=Be(S);if(S.depthTexture.format===xs)B(S)?o.framebufferTexture2DMultisampleEXT(r.FRAMEBUFFER,r.DEPTH_ATTACHMENT,r.TEXTURE_2D,J,0,Z):r.framebufferTexture2D(r.FRAMEBUFFER,r.DEPTH_ATTACHMENT,r.TEXTURE_2D,J,0);else if(S.depthTexture.format===Ds)B(S)?o.framebufferTexture2DMultisampleEXT(r.FRAMEBUFFER,r.DEPTH_STENCIL_ATTACHMENT,r.TEXTURE_2D,J,0,Z):r.framebufferTexture2D(r.FRAMEBUFFER,r.DEPTH_STENCIL_ATTACHMENT,r.TEXTURE_2D,J,0);else throw new Error("Unknown depthTexture format")}function we(A){const S=n.get(A),z=A.isWebGLCubeRenderTarget===!0;if(S.__boundDepthTexture!==A.depthTexture){const Q=A.depthTexture;if(S.__depthDisposeCallback&&S.__depthDisposeCallback(),Q){const J=()=>{delete S.__boundDepthTexture,delete S.__depthDisposeCallback,Q.removeEventListener("dispose",J)};Q.addEventListener("dispose",J),S.__depthDisposeCallback=J}S.__boundDepthTexture=Q}if(A.depthTexture&&!S.__autoAllocateDepthBuffer){if(z)throw new Error("target.depthTexture not supported in Cube render targets");Ee(S.__webglFramebuffer,A)}else if(z){S.__webglDepthbuffer=[];for(let Q=0;Q<6;Q++)if(t.bindFramebuffer(r.FRAMEBUFFER,S.__webglFramebuffer[Q]),S.__webglDepthbuffer[Q]===void 0)S.__webglDepthbuffer[Q]=r.createRenderbuffer(),ie(S.__webglDepthbuffer[Q],A,!1);else{const J=A.stencilBuffer?r.DEPTH_STENCIL_ATTACHMENT:r.DEPTH_ATTACHMENT,Z=S.__webglDepthbuffer[Q];r.bindRenderbuffer(r.RENDERBUFFER,Z),r.framebufferRenderbuffer(r.FRAMEBUFFER,J,r.RENDERBUFFER,Z)}}else if(t.bindFramebuffer(r.FRAMEBUFFER,S.__webglFramebuffer),S.__webglDepthbuffer===void 0)S.__webglDepthbuffer=r.createRenderbuffer(),ie(S.__webglDepthbuffer,A,!1);else{const Q=A.stencilBuffer?r.DEPTH_STENCIL_ATTACHMENT:r.DEPTH_ATTACHMENT,J=S.__webglDepthbuffer;r.bindRenderbuffer(r.RENDERBUFFER,J),r.framebufferRenderbuffer(r.FRAMEBUFFER,Q,r.RENDERBUFFER,J)}t.bindFramebuffer(r.FRAMEBUFFER,null)}function He(A,S,z){const Q=n.get(A);S!==void 0&&_e(Q.__webglFramebuffer,A,A.texture,r.COLOR_ATTACHMENT0,r.TEXTURE_2D,0),z!==void 0&&we(A)}function Ke(A){const S=A.texture,z=n.get(A),Q=n.get(S);A.addEventListener("dispose",b);const J=A.textures,Z=A.isWebGLCubeRenderTarget===!0,fe=J.length>1;if(fe||(Q.__webglTexture===void 0&&(Q.__webglTexture=r.createTexture()),Q.__version=S.version,a.memory.textures++),Z){z.__webglFramebuffer=[];for(let ae=0;ae<6;ae++)if(S.mipmaps&&S.mipmaps.length>0){z.__webglFramebuffer[ae]=[];for(let de=0;de<S.mipmaps.length;de++)z.__webglFramebuffer[ae][de]=r.createFramebuffer()}else z.__webglFramebuffer[ae]=r.createFramebuffer()}else{if(S.mipmaps&&S.mipmaps.length>0){z.__webglFramebuffer=[];for(let ae=0;ae<S.mipmaps.length;ae++)z.__webglFramebuffer[ae]=r.createFramebuffer()}else z.__webglFramebuffer=r.createFramebuffer();if(fe)for(let ae=0,de=J.length;ae<de;ae++){const Ge=n.get(J[ae]);Ge.__webglTexture===void 0&&(Ge.__webglTexture=r.createTexture(),a.memory.textures++)}if(A.samples>0&&B(A)===!1){z.__webglMultisampledFramebuffer=r.createFramebuffer(),z.__webglColorRenderbuffer=[],t.bindFramebuffer(r.FRAMEBUFFER,z.__webglMultisampledFramebuffer);for(let ae=0;ae<J.length;ae++){const de=J[ae];z.__webglColorRenderbuffer[ae]=r.createRenderbuffer(),r.bindRenderbuffer(r.RENDERBUFFER,z.__webglColorRenderbuffer[ae]);const Ge=s.convert(de.format,de.colorSpace),re=s.convert(de.type),se=E(de.internalFormat,Ge,re,de.colorSpace,A.isXRRenderTarget===!0),Le=Be(A);r.renderbufferStorageMultisample(r.RENDERBUFFER,Le,se,A.width,A.height),r.framebufferRenderbuffer(r.FRAMEBUFFER,r.COLOR_ATTACHMENT0+ae,r.RENDERBUFFER,z.__webglColorRenderbuffer[ae])}r.bindRenderbuffer(r.RENDERBUFFER,null),A.depthBuffer&&(z.__webglDepthRenderbuffer=r.createRenderbuffer(),ie(z.__webglDepthRenderbuffer,A,!0)),t.bindFramebuffer(r.FRAMEBUFFER,null)}}if(Z){t.bindTexture(r.TEXTURE_CUBE_MAP,Q.__webglTexture),Ie(r.TEXTURE_CUBE_MAP,S);for(let ae=0;ae<6;ae++)if(S.mipmaps&&S.mipmaps.length>0)for(let de=0;de<S.mipmaps.length;de++)_e(z.__webglFramebuffer[ae][de],A,S,r.COLOR_ATTACHMENT0,r.TEXTURE_CUBE_MAP_POSITIVE_X+ae,de);else _e(z.__webglFramebuffer[ae],A,S,r.COLOR_ATTACHMENT0,r.TEXTURE_CUBE_MAP_POSITIVE_X+ae,0);m(S)&&p(r.TEXTURE_CUBE_MAP),t.unbindTexture()}else if(fe){for(let ae=0,de=J.length;ae<de;ae++){const Ge=J[ae],re=n.get(Ge);t.bindTexture(r.TEXTURE_2D,re.__webglTexture),Ie(r.TEXTURE_2D,Ge),_e(z.__webglFramebuffer,A,Ge,r.COLOR_ATTACHMENT0+ae,r.TEXTURE_2D,0),m(Ge)&&p(r.TEXTURE_2D)}t.unbindTexture()}else{let ae=r.TEXTURE_2D;if((A.isWebGL3DRenderTarget||A.isWebGLArrayRenderTarget)&&(ae=A.isWebGL3DRenderTarget?r.TEXTURE_3D:r.TEXTURE_2D_ARRAY),t.bindTexture(ae,Q.__webglTexture),Ie(ae,S),S.mipmaps&&S.mipmaps.length>0)for(let de=0;de<S.mipmaps.length;de++)_e(z.__webglFramebuffer[de],A,S,r.COLOR_ATTACHMENT0,ae,de);else _e(z.__webglFramebuffer,A,S,r.COLOR_ATTACHMENT0,ae,0);m(S)&&p(ae),t.unbindTexture()}A.depthBuffer&&we(A)}function Fe(A){const S=A.textures;for(let z=0,Q=S.length;z<Q;z++){const J=S[z];if(m(J)){const Z=T(A),fe=n.get(J).__webglTexture;t.bindTexture(Z,fe),p(Z),t.unbindTexture()}}}const Ce=[],I=[];function mt(A){if(A.samples>0){if(B(A)===!1){const S=A.textures,z=A.width,Q=A.height;let J=r.COLOR_BUFFER_BIT;const Z=A.stencilBuffer?r.DEPTH_STENCIL_ATTACHMENT:r.DEPTH_ATTACHMENT,fe=n.get(A),ae=S.length>1;if(ae)for(let de=0;de<S.length;de++)t.bindFramebuffer(r.FRAMEBUFFER,fe.__webglMultisampledFramebuffer),r.framebufferRenderbuffer(r.FRAMEBUFFER,r.COLOR_ATTACHMENT0+de,r.RENDERBUFFER,null),t.bindFramebuffer(r.FRAMEBUFFER,fe.__webglFramebuffer),r.framebufferTexture2D(r.DRAW_FRAMEBUFFER,r.COLOR_ATTACHMENT0+de,r.TEXTURE_2D,null,0);t.bindFramebuffer(r.READ_FRAMEBUFFER,fe.__webglMultisampledFramebuffer),t.bindFramebuffer(r.DRAW_FRAMEBUFFER,fe.__webglFramebuffer);for(let de=0;de<S.length;de++){if(A.resolveDepthBuffer&&(A.depthBuffer&&(J|=r.DEPTH_BUFFER_BIT),A.stencilBuffer&&A.resolveStencilBuffer&&(J|=r.STENCIL_BUFFER_BIT)),ae){r.framebufferRenderbuffer(r.READ_FRAMEBUFFER,r.COLOR_ATTACHMENT0,r.RENDERBUFFER,fe.__webglColorRenderbuffer[de]);const Ge=n.get(S[de]).__webglTexture;r.framebufferTexture2D(r.DRAW_FRAMEBUFFER,r.COLOR_ATTACHMENT0,r.TEXTURE_2D,Ge,0)}r.blitFramebuffer(0,0,z,Q,0,0,z,Q,J,r.NEAREST),l===!0&&(Ce.length=0,I.length=0,Ce.push(r.COLOR_ATTACHMENT0+de),A.depthBuffer&&A.resolveDepthBuffer===!1&&(Ce.push(Z),I.push(Z),r.invalidateFramebuffer(r.DRAW_FRAMEBUFFER,I)),r.invalidateFramebuffer(r.READ_FRAMEBUFFER,Ce))}if(t.bindFramebuffer(r.READ_FRAMEBUFFER,null),t.bindFramebuffer(r.DRAW_FRAMEBUFFER,null),ae)for(let de=0;de<S.length;de++){t.bindFramebuffer(r.FRAMEBUFFER,fe.__webglMultisampledFramebuffer),r.framebufferRenderbuffer(r.FRAMEBUFFER,r.COLOR_ATTACHMENT0+de,r.RENDERBUFFER,fe.__webglColorRenderbuffer[de]);const Ge=n.get(S[de]).__webglTexture;t.bindFramebuffer(r.FRAMEBUFFER,fe.__webglFramebuffer),r.framebufferTexture2D(r.DRAW_FRAMEBUFFER,r.COLOR_ATTACHMENT0+de,r.TEXTURE_2D,Ge,0)}t.bindFramebuffer(r.DRAW_FRAMEBUFFER,fe.__webglMultisampledFramebuffer)}else if(A.depthBuffer&&A.resolveDepthBuffer===!1&&l){const S=A.stencilBuffer?r.DEPTH_STENCIL_ATTACHMENT:r.DEPTH_ATTACHMENT;r.invalidateFramebuffer(r.DRAW_FRAMEBUFFER,[S])}}}function Be(A){return Math.min(i.maxSamples,A.samples)}function B(A){const S=n.get(A);return A.samples>0&&e.has("WEBGL_multisampled_render_to_texture")===!0&&S.__useRenderToTexture!==!1}function Me(A){const S=a.render.frame;u.get(A)!==S&&(u.set(A,S),A.update())}function rt(A,S){const z=A.colorSpace,Q=A.format,J=A.type;return A.isCompressedTexture===!0||A.isVideoTexture===!0||z!==Ls&&z!==Zi&&(ut.getTransfer(z)===pt?(Q!==ui||J!==zi)&&console.warn("THREE.WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType."):console.error("THREE.WebGLTextures: Unsupported texture color space:",z)),S}function Te(A){return typeof HTMLImageElement<"u"&&A instanceof HTMLImageElement?(c.width=A.naturalWidth||A.width,c.height=A.naturalHeight||A.height):typeof VideoFrame<"u"&&A instanceof VideoFrame?(c.width=A.displayWidth,c.height=A.displayHeight):(c.width=A.width,c.height=A.height),c}this.allocateTextureUnit=O,this.resetTextureUnits=U,this.setTexture2D=Y,this.setTexture2DArray=H,this.setTexture3D=q,this.setTextureCube=k,this.rebindTextures=He,this.setupRenderTarget=Ke,this.updateRenderTargetMipmap=Fe,this.updateMultisampleRenderTarget=mt,this.setupDepthRenderbuffer=we,this.setupFrameBufferTexture=_e,this.useMultisampledRTT=B}function Nx(r,e){function t(n,i=Zi){let s;const a=ut.getTransfer(i);if(n===zi)return r.UNSIGNED_BYTE;if(n===_u)return r.UNSIGNED_SHORT_4_4_4_4;if(n===gu)return r.UNSIGNED_SHORT_5_5_5_1;if(n===Bh)return r.UNSIGNED_INT_5_9_9_9_REV;if(n===Fh)return r.BYTE;if(n===Oh)return r.SHORT;if(n===Sa)return r.UNSIGNED_SHORT;if(n===mu)return r.INT;if(n===Hr)return r.UNSIGNED_INT;if(n===Li)return r.FLOAT;if(n===Da)return r.HALF_FLOAT;if(n===zh)return r.ALPHA;if(n===kh)return r.RGB;if(n===ui)return r.RGBA;if(n===Hh)return r.LUMINANCE;if(n===Vh)return r.LUMINANCE_ALPHA;if(n===xs)return r.DEPTH_COMPONENT;if(n===Ds)return r.DEPTH_STENCIL;if(n===Gh)return r.RED;if(n===vu)return r.RED_INTEGER;if(n===Wh)return r.RG;if(n===xu)return r.RG_INTEGER;if(n===Mu)return r.RGBA_INTEGER;if(n===To||n===bo||n===Ao||n===wo)if(a===pt)if(s=e.get("WEBGL_compressed_texture_s3tc_srgb"),s!==null){if(n===To)return s.COMPRESSED_SRGB_S3TC_DXT1_EXT;if(n===bo)return s.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;if(n===Ao)return s.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;if(n===wo)return s.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT}else return null;else if(s=e.get("WEBGL_compressed_texture_s3tc"),s!==null){if(n===To)return s.COMPRESSED_RGB_S3TC_DXT1_EXT;if(n===bo)return s.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(n===Ao)return s.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(n===wo)return s.COMPRESSED_RGBA_S3TC_DXT5_EXT}else return null;if(n===mc||n===_c||n===gc||n===vc)if(s=e.get("WEBGL_compressed_texture_pvrtc"),s!==null){if(n===mc)return s.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(n===_c)return s.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(n===gc)return s.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(n===vc)return s.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}else return null;if(n===xc||n===Mc||n===Sc)if(s=e.get("WEBGL_compressed_texture_etc"),s!==null){if(n===xc||n===Mc)return a===pt?s.COMPRESSED_SRGB8_ETC2:s.COMPRESSED_RGB8_ETC2;if(n===Sc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC:s.COMPRESSED_RGBA8_ETC2_EAC}else return null;if(n===yc||n===Ec||n===Tc||n===bc||n===Ac||n===wc||n===Rc||n===Cc||n===Pc||n===Dc||n===Lc||n===Ic||n===Uc||n===Nc)if(s=e.get("WEBGL_compressed_texture_astc"),s!==null){if(n===yc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR:s.COMPRESSED_RGBA_ASTC_4x4_KHR;if(n===Ec)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR:s.COMPRESSED_RGBA_ASTC_5x4_KHR;if(n===Tc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR:s.COMPRESSED_RGBA_ASTC_5x5_KHR;if(n===bc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR:s.COMPRESSED_RGBA_ASTC_6x5_KHR;if(n===Ac)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR:s.COMPRESSED_RGBA_ASTC_6x6_KHR;if(n===wc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR:s.COMPRESSED_RGBA_ASTC_8x5_KHR;if(n===Rc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR:s.COMPRESSED_RGBA_ASTC_8x6_KHR;if(n===Cc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR:s.COMPRESSED_RGBA_ASTC_8x8_KHR;if(n===Pc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR:s.COMPRESSED_RGBA_ASTC_10x5_KHR;if(n===Dc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR:s.COMPRESSED_RGBA_ASTC_10x6_KHR;if(n===Lc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR:s.COMPRESSED_RGBA_ASTC_10x8_KHR;if(n===Ic)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR:s.COMPRESSED_RGBA_ASTC_10x10_KHR;if(n===Uc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR:s.COMPRESSED_RGBA_ASTC_12x10_KHR;if(n===Nc)return a===pt?s.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR:s.COMPRESSED_RGBA_ASTC_12x12_KHR}else return null;if(n===Ro||n===Fc||n===Oc)if(s=e.get("EXT_texture_compression_bptc"),s!==null){if(n===Ro)return a===pt?s.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT:s.COMPRESSED_RGBA_BPTC_UNORM_EXT;if(n===Fc)return s.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;if(n===Oc)return s.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT}else return null;if(n===Xh||n===Bc||n===zc||n===kc)if(s=e.get("EXT_texture_compression_rgtc"),s!==null){if(n===Ro)return s.COMPRESSED_RED_RGTC1_EXT;if(n===Bc)return s.COMPRESSED_SIGNED_RED_RGTC1_EXT;if(n===zc)return s.COMPRESSED_RED_GREEN_RGTC2_EXT;if(n===kc)return s.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT}else return null;return n===Ps?r.UNSIGNED_INT_24_8:r[n]!==void 0?r[n]:null}return{convert:t}}const Fx={type:"move"};class kl{constructor(){this._targetRay=null,this._grip=null,this._hand=null}getHandSpace(){return this._hand===null&&(this._hand=new ao,this._hand.matrixAutoUpdate=!1,this._hand.visible=!1,this._hand.joints={},this._hand.inputState={pinching:!1}),this._hand}getTargetRaySpace(){return this._targetRay===null&&(this._targetRay=new ao,this._targetRay.matrixAutoUpdate=!1,this._targetRay.visible=!1,this._targetRay.hasLinearVelocity=!1,this._targetRay.linearVelocity=new X,this._targetRay.hasAngularVelocity=!1,this._targetRay.angularVelocity=new X),this._targetRay}getGripSpace(){return this._grip===null&&(this._grip=new ao,this._grip.matrixAutoUpdate=!1,this._grip.visible=!1,this._grip.hasLinearVelocity=!1,this._grip.linearVelocity=new X,this._grip.hasAngularVelocity=!1,this._grip.angularVelocity=new X),this._grip}dispatchEvent(e){return this._targetRay!==null&&this._targetRay.dispatchEvent(e),this._grip!==null&&this._grip.dispatchEvent(e),this._hand!==null&&this._hand.dispatchEvent(e),this}connect(e){if(e&&e.hand){const t=this._hand;if(t)for(const n of e.hand.values())this._getHandJoint(t,n)}return this.dispatchEvent({type:"connected",data:e}),this}disconnect(e){return this.dispatchEvent({type:"disconnected",data:e}),this._targetRay!==null&&(this._targetRay.visible=!1),this._grip!==null&&(this._grip.visible=!1),this._hand!==null&&(this._hand.visible=!1),this}update(e,t,n){let i=null,s=null,a=null;const o=this._targetRay,l=this._grip,c=this._hand;if(e&&t.session.visibilityState!=="visible-blurred"){if(c&&e.hand){a=!0;for(const _ of e.hand.values()){const m=t.getJointPose(_,n),p=this._getHandJoint(c,_);m!==null&&(p.matrix.fromArray(m.transform.matrix),p.matrix.decompose(p.position,p.rotation,p.scale),p.matrixWorldNeedsUpdate=!0,p.jointRadius=m.radius),p.visible=m!==null}const u=c.joints["index-finger-tip"],h=c.joints["thumb-tip"],d=u.position.distanceTo(h.position),f=.02,g=.005;c.inputState.pinching&&d>f+g?(c.inputState.pinching=!1,this.dispatchEvent({type:"pinchend",handedness:e.handedness,target:this})):!c.inputState.pinching&&d<=f-g&&(c.inputState.pinching=!0,this.dispatchEvent({type:"pinchstart",handedness:e.handedness,target:this}))}else l!==null&&e.gripSpace&&(s=t.getPose(e.gripSpace,n),s!==null&&(l.matrix.fromArray(s.transform.matrix),l.matrix.decompose(l.position,l.rotation,l.scale),l.matrixWorldNeedsUpdate=!0,s.linearVelocity?(l.hasLinearVelocity=!0,l.linearVelocity.copy(s.linearVelocity)):l.hasLinearVelocity=!1,s.angularVelocity?(l.hasAngularVelocity=!0,l.angularVelocity.copy(s.angularVelocity)):l.hasAngularVelocity=!1));o!==null&&(i=t.getPose(e.targetRaySpace,n),i===null&&s!==null&&(i=s),i!==null&&(o.matrix.fromArray(i.transform.matrix),o.matrix.decompose(o.position,o.rotation,o.scale),o.matrixWorldNeedsUpdate=!0,i.linearVelocity?(o.hasLinearVelocity=!0,o.linearVelocity.copy(i.linearVelocity)):o.hasLinearVelocity=!1,i.angularVelocity?(o.hasAngularVelocity=!0,o.angularVelocity.copy(i.angularVelocity)):o.hasAngularVelocity=!1,this.dispatchEvent(Fx)))}return o!==null&&(o.visible=i!==null),l!==null&&(l.visible=s!==null),c!==null&&(c.visible=a!==null),this}_getHandJoint(e,t){if(e.joints[t.jointName]===void 0){const n=new ao;n.matrixAutoUpdate=!1,n.visible=!1,e.joints[t.jointName]=n,e.add(n)}return e.joints[t.jointName]}}const Ox=`
void main() {

	gl_Position = vec4( position, 1.0 );

}`,Bx=`
uniform sampler2DArray depthColor;
uniform float depthWidth;
uniform float depthHeight;

void main() {

	vec2 coord = vec2( gl_FragCoord.x / depthWidth, gl_FragCoord.y / depthHeight );

	if ( coord.x >= 1.0 ) {

		gl_FragDepth = texture( depthColor, vec3( coord.x - 1.0, coord.y, 1 ) ).r;

	} else {

		gl_FragDepth = texture( depthColor, vec3( coord.x, coord.y, 0 ) ).r;

	}

}`;class zx{constructor(){this.texture=null,this.mesh=null,this.depthNear=0,this.depthFar=0}init(e,t,n){if(this.texture===null){const i=new bn,s=e.properties.get(i);s.__webglTexture=t.texture,(t.depthNear!=n.depthNear||t.depthFar!=n.depthFar)&&(this.depthNear=t.depthNear,this.depthFar=t.depthFar),this.texture=i}}getMesh(e){if(this.texture!==null&&this.mesh===null){const t=e.cameras[0].viewport,n=new lr({vertexShader:Ox,fragmentShader:Bx,uniforms:{depthColor:{value:this.texture},depthWidth:{value:t.z},depthHeight:{value:t.w}}});this.mesh=new Ui(new il(20,20),n)}return this.mesh}reset(){this.texture=null,this.mesh=null}getDepthTexture(){return this.texture}}class kx extends Hs{constructor(e,t){super();const n=this;let i=null,s=1,a=null,o="local-floor",l=1,c=null,u=null,h=null,d=null,f=null,g=null;const _=new zx,m=t.getContextAttributes();let p=null,T=null;const E=[],x=[],R=new Mt;let w=null;const b=new Jn;b.viewport=new Nt;const C=new Jn;C.viewport=new Nt;const M=[b,C],v=new a_;let P=null,U=null;this.cameraAutoUpdate=!0,this.enabled=!1,this.isPresenting=!1,this.getController=function(K){let te=E[K];return te===void 0&&(te=new kl,E[K]=te),te.getTargetRaySpace()},this.getControllerGrip=function(K){let te=E[K];return te===void 0&&(te=new kl,E[K]=te),te.getGripSpace()},this.getHand=function(K){let te=E[K];return te===void 0&&(te=new kl,E[K]=te),te.getHandSpace()};function O(K){const te=x.indexOf(K.inputSource);if(te===-1)return;const _e=E[te];_e!==void 0&&(_e.update(K.inputSource,K.frame,c||a),_e.dispatchEvent({type:K.type,data:K.inputSource}))}function G(){i.removeEventListener("select",O),i.removeEventListener("selectstart",O),i.removeEventListener("selectend",O),i.removeEventListener("squeeze",O),i.removeEventListener("squeezestart",O),i.removeEventListener("squeezeend",O),i.removeEventListener("end",G),i.removeEventListener("inputsourceschange",Y);for(let K=0;K<E.length;K++){const te=x[K];te!==null&&(x[K]=null,E[K].disconnect(te))}P=null,U=null,_.reset(),e.setRenderTarget(p),f=null,d=null,h=null,i=null,T=null,$e.stop(),n.isPresenting=!1,e.setPixelRatio(w),e.setSize(R.width,R.height,!1),n.dispatchEvent({type:"sessionend"})}this.setFramebufferScaleFactor=function(K){s=K,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change framebuffer scale while presenting.")},this.setReferenceSpaceType=function(K){o=K,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change reference space type while presenting.")},this.getReferenceSpace=function(){return c||a},this.setReferenceSpace=function(K){c=K},this.getBaseLayer=function(){return d!==null?d:f},this.getBinding=function(){return h},this.getFrame=function(){return g},this.getSession=function(){return i},this.setSession=async function(K){if(i=K,i!==null){if(p=e.getRenderTarget(),i.addEventListener("select",O),i.addEventListener("selectstart",O),i.addEventListener("selectend",O),i.addEventListener("squeeze",O),i.addEventListener("squeezestart",O),i.addEventListener("squeezeend",O),i.addEventListener("end",G),i.addEventListener("inputsourceschange",Y),m.xrCompatible!==!0&&await t.makeXRCompatible(),w=e.getPixelRatio(),e.getSize(R),i.renderState.layers===void 0){const te={antialias:m.antialias,alpha:!0,depth:m.depth,stencil:m.stencil,framebufferScaleFactor:s};f=new XRWebGLLayer(i,t,te),i.updateRenderState({baseLayer:f}),e.setPixelRatio(1),e.setSize(f.framebufferWidth,f.framebufferHeight,!1),T=new Vr(f.framebufferWidth,f.framebufferHeight,{format:ui,type:zi,colorSpace:e.outputColorSpace,stencilBuffer:m.stencil})}else{let te=null,_e=null,ie=null;m.depth&&(ie=m.stencil?t.DEPTH24_STENCIL8:t.DEPTH_COMPONENT24,te=m.stencil?Ds:xs,_e=m.stencil?Ps:Hr);const Ee={colorFormat:t.RGBA8,depthFormat:ie,scaleFactor:s};h=new XRWebGLBinding(i,t),d=h.createProjectionLayer(Ee),i.updateRenderState({layers:[d]}),e.setPixelRatio(1),e.setSize(d.textureWidth,d.textureHeight,!1),T=new Vr(d.textureWidth,d.textureHeight,{format:ui,type:zi,depthTexture:new od(d.textureWidth,d.textureHeight,_e,void 0,void 0,void 0,void 0,void 0,void 0,te),stencilBuffer:m.stencil,colorSpace:e.outputColorSpace,samples:m.antialias?4:0,resolveDepthBuffer:d.ignoreDepthValues===!1})}T.isXRRenderTarget=!0,this.setFoveation(l),c=null,a=await i.requestReferenceSpace(o),$e.setContext(i),$e.start(),n.isPresenting=!0,n.dispatchEvent({type:"sessionstart"})}},this.getEnvironmentBlendMode=function(){if(i!==null)return i.environmentBlendMode},this.getDepthTexture=function(){return _.getDepthTexture()};function Y(K){for(let te=0;te<K.removed.length;te++){const _e=K.removed[te],ie=x.indexOf(_e);ie>=0&&(x[ie]=null,E[ie].disconnect(_e))}for(let te=0;te<K.added.length;te++){const _e=K.added[te];let ie=x.indexOf(_e);if(ie===-1){for(let we=0;we<E.length;we++)if(we>=x.length){x.push(_e),ie=we;break}else if(x[we]===null){x[we]=_e,ie=we;break}if(ie===-1)break}const Ee=E[ie];Ee&&Ee.connect(_e)}}const H=new X,q=new X;function k(K,te,_e){H.setFromMatrixPosition(te.matrixWorld),q.setFromMatrixPosition(_e.matrixWorld);const ie=H.distanceTo(q),Ee=te.projectionMatrix.elements,we=_e.projectionMatrix.elements,He=Ee[14]/(Ee[10]-1),Ke=Ee[14]/(Ee[10]+1),Fe=(Ee[9]+1)/Ee[5],Ce=(Ee[9]-1)/Ee[5],I=(Ee[8]-1)/Ee[0],mt=(we[8]+1)/we[0],Be=He*I,B=He*mt,Me=ie/(-I+mt),rt=Me*-I;if(te.matrixWorld.decompose(K.position,K.quaternion,K.scale),K.translateX(rt),K.translateZ(Me),K.matrixWorld.compose(K.position,K.quaternion,K.scale),K.matrixWorldInverse.copy(K.matrixWorld).invert(),Ee[10]===-1)K.projectionMatrix.copy(te.projectionMatrix),K.projectionMatrixInverse.copy(te.projectionMatrixInverse);else{const Te=He+Me,A=Ke+Me,S=Be-rt,z=B+(ie-rt),Q=Fe*Ke/A*Te,J=Ce*Ke/A*Te;K.projectionMatrix.makePerspective(S,z,Q,J,Te,A),K.projectionMatrixInverse.copy(K.projectionMatrix).invert()}}function ne(K,te){te===null?K.matrixWorld.copy(K.matrix):K.matrixWorld.multiplyMatrices(te.matrixWorld,K.matrix),K.matrixWorldInverse.copy(K.matrixWorld).invert()}this.updateCamera=function(K){if(i===null)return;let te=K.near,_e=K.far;_.texture!==null&&(_.depthNear>0&&(te=_.depthNear),_.depthFar>0&&(_e=_.depthFar)),v.near=C.near=b.near=te,v.far=C.far=b.far=_e,(P!==v.near||U!==v.far)&&(i.updateRenderState({depthNear:v.near,depthFar:v.far}),P=v.near,U=v.far),b.layers.mask=K.layers.mask|2,C.layers.mask=K.layers.mask|4,v.layers.mask=b.layers.mask|C.layers.mask;const ie=K.parent,Ee=v.cameras;ne(v,ie);for(let we=0;we<Ee.length;we++)ne(Ee[we],ie);Ee.length===2?k(v,b,C):v.projectionMatrix.copy(b.projectionMatrix),D(K,v,ie)};function D(K,te,_e){_e===null?K.matrix.copy(te.matrixWorld):(K.matrix.copy(_e.matrixWorld),K.matrix.invert(),K.matrix.multiply(te.matrixWorld)),K.matrix.decompose(K.position,K.quaternion,K.scale),K.updateMatrixWorld(!0),K.projectionMatrix.copy(te.projectionMatrix),K.projectionMatrixInverse.copy(te.projectionMatrixInverse),K.isPerspectiveCamera&&(K.fov=Hc*2*Math.atan(1/K.projectionMatrix.elements[5]),K.zoom=1)}this.getCamera=function(){return v},this.getFoveation=function(){if(!(d===null&&f===null))return l},this.setFoveation=function(K){l=K,d!==null&&(d.fixedFoveation=K),f!==null&&f.fixedFoveation!==void 0&&(f.fixedFoveation=K)},this.hasDepthSensing=function(){return _.texture!==null},this.getDepthSensingMesh=function(){return _.getMesh(v)};let ue=null;function Ie(K,te){if(u=te.getViewerPose(c||a),g=te,u!==null){const _e=u.views;f!==null&&(e.setRenderTargetFramebuffer(T,f.framebuffer),e.setRenderTarget(T));let ie=!1;_e.length!==v.cameras.length&&(v.cameras.length=0,ie=!0);for(let we=0;we<_e.length;we++){const He=_e[we];let Ke=null;if(f!==null)Ke=f.getViewport(He);else{const Ce=h.getViewSubImage(d,He);Ke=Ce.viewport,we===0&&(e.setRenderTargetTextures(T,Ce.colorTexture,d.ignoreDepthValues?void 0:Ce.depthStencilTexture),e.setRenderTarget(T))}let Fe=M[we];Fe===void 0&&(Fe=new Jn,Fe.layers.enable(we),Fe.viewport=new Nt,M[we]=Fe),Fe.matrix.fromArray(He.transform.matrix),Fe.matrix.decompose(Fe.position,Fe.quaternion,Fe.scale),Fe.projectionMatrix.fromArray(He.projectionMatrix),Fe.projectionMatrixInverse.copy(Fe.projectionMatrix).invert(),Fe.viewport.set(Ke.x,Ke.y,Ke.width,Ke.height),we===0&&(v.matrix.copy(Fe.matrix),v.matrix.decompose(v.position,v.quaternion,v.scale)),ie===!0&&v.cameras.push(Fe)}const Ee=i.enabledFeatures;if(Ee&&Ee.includes("depth-sensing")){const we=h.getDepthInformation(_e[0]);we&&we.isValid&&we.texture&&_.init(e,we,i.renderState)}}for(let _e=0;_e<E.length;_e++){const ie=x[_e],Ee=E[_e];ie!==null&&Ee!==void 0&&Ee.update(ie,te,c||a)}ue&&ue(K,te),te.detectedPlanes&&n.dispatchEvent({type:"planesdetected",data:te}),g=null}const $e=new ld;$e.setAnimationLoop(Ie),this.setAnimationLoop=function(K){ue=K},this.dispose=function(){}}}const Mr=new ki,Hx=new Lt;function Vx(r,e){function t(m,p){m.matrixAutoUpdate===!0&&m.updateMatrix(),p.value.copy(m.matrix)}function n(m,p){p.color.getRGB(m.fogColor.value,td(r)),p.isFog?(m.fogNear.value=p.near,m.fogFar.value=p.far):p.isFogExp2&&(m.fogDensity.value=p.density)}function i(m,p,T,E,x){p.isMeshBasicMaterial||p.isMeshLambertMaterial?s(m,p):p.isMeshToonMaterial?(s(m,p),h(m,p)):p.isMeshPhongMaterial?(s(m,p),u(m,p)):p.isMeshStandardMaterial?(s(m,p),d(m,p),p.isMeshPhysicalMaterial&&f(m,p,x)):p.isMeshMatcapMaterial?(s(m,p),g(m,p)):p.isMeshDepthMaterial?s(m,p):p.isMeshDistanceMaterial?(s(m,p),_(m,p)):p.isMeshNormalMaterial?s(m,p):p.isLineBasicMaterial?(a(m,p),p.isLineDashedMaterial&&o(m,p)):p.isPointsMaterial?l(m,p,T,E):p.isSpriteMaterial?c(m,p):p.isShadowMaterial?(m.color.value.copy(p.color),m.opacity.value=p.opacity):p.isShaderMaterial&&(p.uniformsNeedUpdate=!1)}function s(m,p){m.opacity.value=p.opacity,p.color&&m.diffuse.value.copy(p.color),p.emissive&&m.emissive.value.copy(p.emissive).multiplyScalar(p.emissiveIntensity),p.map&&(m.map.value=p.map,t(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,t(p.alphaMap,m.alphaMapTransform)),p.bumpMap&&(m.bumpMap.value=p.bumpMap,t(p.bumpMap,m.bumpMapTransform),m.bumpScale.value=p.bumpScale,p.side===Tn&&(m.bumpScale.value*=-1)),p.normalMap&&(m.normalMap.value=p.normalMap,t(p.normalMap,m.normalMapTransform),m.normalScale.value.copy(p.normalScale),p.side===Tn&&m.normalScale.value.negate()),p.displacementMap&&(m.displacementMap.value=p.displacementMap,t(p.displacementMap,m.displacementMapTransform),m.displacementScale.value=p.displacementScale,m.displacementBias.value=p.displacementBias),p.emissiveMap&&(m.emissiveMap.value=p.emissiveMap,t(p.emissiveMap,m.emissiveMapTransform)),p.specularMap&&(m.specularMap.value=p.specularMap,t(p.specularMap,m.specularMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest);const T=e.get(p),E=T.envMap,x=T.envMapRotation;E&&(m.envMap.value=E,Mr.copy(x),Mr.x*=-1,Mr.y*=-1,Mr.z*=-1,E.isCubeTexture&&E.isRenderTargetTexture===!1&&(Mr.y*=-1,Mr.z*=-1),m.envMapRotation.value.setFromMatrix4(Hx.makeRotationFromEuler(Mr)),m.flipEnvMap.value=E.isCubeTexture&&E.isRenderTargetTexture===!1?-1:1,m.reflectivity.value=p.reflectivity,m.ior.value=p.ior,m.refractionRatio.value=p.refractionRatio),p.lightMap&&(m.lightMap.value=p.lightMap,m.lightMapIntensity.value=p.lightMapIntensity,t(p.lightMap,m.lightMapTransform)),p.aoMap&&(m.aoMap.value=p.aoMap,m.aoMapIntensity.value=p.aoMapIntensity,t(p.aoMap,m.aoMapTransform))}function a(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,p.map&&(m.map.value=p.map,t(p.map,m.mapTransform))}function o(m,p){m.dashSize.value=p.dashSize,m.totalSize.value=p.dashSize+p.gapSize,m.scale.value=p.scale}function l(m,p,T,E){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.size.value=p.size*T,m.scale.value=E*.5,p.map&&(m.map.value=p.map,t(p.map,m.uvTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,t(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function c(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.rotation.value=p.rotation,p.map&&(m.map.value=p.map,t(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,t(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function u(m,p){m.specular.value.copy(p.specular),m.shininess.value=Math.max(p.shininess,1e-4)}function h(m,p){p.gradientMap&&(m.gradientMap.value=p.gradientMap)}function d(m,p){m.metalness.value=p.metalness,p.metalnessMap&&(m.metalnessMap.value=p.metalnessMap,t(p.metalnessMap,m.metalnessMapTransform)),m.roughness.value=p.roughness,p.roughnessMap&&(m.roughnessMap.value=p.roughnessMap,t(p.roughnessMap,m.roughnessMapTransform)),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)}function f(m,p,T){m.ior.value=p.ior,p.sheen>0&&(m.sheenColor.value.copy(p.sheenColor).multiplyScalar(p.sheen),m.sheenRoughness.value=p.sheenRoughness,p.sheenColorMap&&(m.sheenColorMap.value=p.sheenColorMap,t(p.sheenColorMap,m.sheenColorMapTransform)),p.sheenRoughnessMap&&(m.sheenRoughnessMap.value=p.sheenRoughnessMap,t(p.sheenRoughnessMap,m.sheenRoughnessMapTransform))),p.clearcoat>0&&(m.clearcoat.value=p.clearcoat,m.clearcoatRoughness.value=p.clearcoatRoughness,p.clearcoatMap&&(m.clearcoatMap.value=p.clearcoatMap,t(p.clearcoatMap,m.clearcoatMapTransform)),p.clearcoatRoughnessMap&&(m.clearcoatRoughnessMap.value=p.clearcoatRoughnessMap,t(p.clearcoatRoughnessMap,m.clearcoatRoughnessMapTransform)),p.clearcoatNormalMap&&(m.clearcoatNormalMap.value=p.clearcoatNormalMap,t(p.clearcoatNormalMap,m.clearcoatNormalMapTransform),m.clearcoatNormalScale.value.copy(p.clearcoatNormalScale),p.side===Tn&&m.clearcoatNormalScale.value.negate())),p.dispersion>0&&(m.dispersion.value=p.dispersion),p.iridescence>0&&(m.iridescence.value=p.iridescence,m.iridescenceIOR.value=p.iridescenceIOR,m.iridescenceThicknessMinimum.value=p.iridescenceThicknessRange[0],m.iridescenceThicknessMaximum.value=p.iridescenceThicknessRange[1],p.iridescenceMap&&(m.iridescenceMap.value=p.iridescenceMap,t(p.iridescenceMap,m.iridescenceMapTransform)),p.iridescenceThicknessMap&&(m.iridescenceThicknessMap.value=p.iridescenceThicknessMap,t(p.iridescenceThicknessMap,m.iridescenceThicknessMapTransform))),p.transmission>0&&(m.transmission.value=p.transmission,m.transmissionSamplerMap.value=T.texture,m.transmissionSamplerSize.value.set(T.width,T.height),p.transmissionMap&&(m.transmissionMap.value=p.transmissionMap,t(p.transmissionMap,m.transmissionMapTransform)),m.thickness.value=p.thickness,p.thicknessMap&&(m.thicknessMap.value=p.thicknessMap,t(p.thicknessMap,m.thicknessMapTransform)),m.attenuationDistance.value=p.attenuationDistance,m.attenuationColor.value.copy(p.attenuationColor)),p.anisotropy>0&&(m.anisotropyVector.value.set(p.anisotropy*Math.cos(p.anisotropyRotation),p.anisotropy*Math.sin(p.anisotropyRotation)),p.anisotropyMap&&(m.anisotropyMap.value=p.anisotropyMap,t(p.anisotropyMap,m.anisotropyMapTransform))),m.specularIntensity.value=p.specularIntensity,m.specularColor.value.copy(p.specularColor),p.specularColorMap&&(m.specularColorMap.value=p.specularColorMap,t(p.specularColorMap,m.specularColorMapTransform)),p.specularIntensityMap&&(m.specularIntensityMap.value=p.specularIntensityMap,t(p.specularIntensityMap,m.specularIntensityMapTransform))}function g(m,p){p.matcap&&(m.matcap.value=p.matcap)}function _(m,p){const T=e.get(p).light;m.referencePosition.value.setFromMatrixPosition(T.matrixWorld),m.nearDistance.value=T.shadow.camera.near,m.farDistance.value=T.shadow.camera.far}return{refreshFogUniforms:n,refreshMaterialUniforms:i}}function Gx(r,e,t,n){let i={},s={},a=[];const o=r.getParameter(r.MAX_UNIFORM_BUFFER_BINDINGS);function l(T,E){const x=E.program;n.uniformBlockBinding(T,x)}function c(T,E){let x=i[T.id];x===void 0&&(g(T),x=u(T),i[T.id]=x,T.addEventListener("dispose",m));const R=E.program;n.updateUBOMapping(T,R);const w=e.render.frame;s[T.id]!==w&&(d(T),s[T.id]=w)}function u(T){const E=h();T.__bindingPointIndex=E;const x=r.createBuffer(),R=T.__size,w=T.usage;return r.bindBuffer(r.UNIFORM_BUFFER,x),r.bufferData(r.UNIFORM_BUFFER,R,w),r.bindBuffer(r.UNIFORM_BUFFER,null),r.bindBufferBase(r.UNIFORM_BUFFER,E,x),x}function h(){for(let T=0;T<o;T++)if(a.indexOf(T)===-1)return a.push(T),T;return console.error("THREE.WebGLRenderer: Maximum number of simultaneously usable uniforms groups reached."),0}function d(T){const E=i[T.id],x=T.uniforms,R=T.__cache;r.bindBuffer(r.UNIFORM_BUFFER,E);for(let w=0,b=x.length;w<b;w++){const C=Array.isArray(x[w])?x[w]:[x[w]];for(let M=0,v=C.length;M<v;M++){const P=C[M];if(f(P,w,M,R)===!0){const U=P.__offset,O=Array.isArray(P.value)?P.value:[P.value];let G=0;for(let Y=0;Y<O.length;Y++){const H=O[Y],q=_(H);typeof H=="number"||typeof H=="boolean"?(P.__data[0]=H,r.bufferSubData(r.UNIFORM_BUFFER,U+G,P.__data)):H.isMatrix3?(P.__data[0]=H.elements[0],P.__data[1]=H.elements[1],P.__data[2]=H.elements[2],P.__data[3]=0,P.__data[4]=H.elements[3],P.__data[5]=H.elements[4],P.__data[6]=H.elements[5],P.__data[7]=0,P.__data[8]=H.elements[6],P.__data[9]=H.elements[7],P.__data[10]=H.elements[8],P.__data[11]=0):(H.toArray(P.__data,G),G+=q.storage/Float32Array.BYTES_PER_ELEMENT)}r.bufferSubData(r.UNIFORM_BUFFER,U,P.__data)}}}r.bindBuffer(r.UNIFORM_BUFFER,null)}function f(T,E,x,R){const w=T.value,b=E+"_"+x;if(R[b]===void 0)return typeof w=="number"||typeof w=="boolean"?R[b]=w:R[b]=w.clone(),!0;{const C=R[b];if(typeof w=="number"||typeof w=="boolean"){if(C!==w)return R[b]=w,!0}else if(C.equals(w)===!1)return C.copy(w),!0}return!1}function g(T){const E=T.uniforms;let x=0;const R=16;for(let b=0,C=E.length;b<C;b++){const M=Array.isArray(E[b])?E[b]:[E[b]];for(let v=0,P=M.length;v<P;v++){const U=M[v],O=Array.isArray(U.value)?U.value:[U.value];for(let G=0,Y=O.length;G<Y;G++){const H=O[G],q=_(H),k=x%R,ne=k%q.boundary,D=k+ne;x+=ne,D!==0&&R-D<q.storage&&(x+=R-D),U.__data=new Float32Array(q.storage/Float32Array.BYTES_PER_ELEMENT),U.__offset=x,x+=q.storage}}}const w=x%R;return w>0&&(x+=R-w),T.__size=x,T.__cache={},this}function _(T){const E={boundary:0,storage:0};return typeof T=="number"||typeof T=="boolean"?(E.boundary=4,E.storage=4):T.isVector2?(E.boundary=8,E.storage=8):T.isVector3||T.isColor?(E.boundary=16,E.storage=12):T.isVector4?(E.boundary=16,E.storage=16):T.isMatrix3?(E.boundary=48,E.storage=48):T.isMatrix4?(E.boundary=64,E.storage=64):T.isTexture?console.warn("THREE.WebGLRenderer: Texture samplers can not be part of an uniforms group."):console.warn("THREE.WebGLRenderer: Unsupported uniform value type.",T),E}function m(T){const E=T.target;E.removeEventListener("dispose",m);const x=a.indexOf(E.__bindingPointIndex);a.splice(x,1),r.deleteBuffer(i[E.id]),delete i[E.id],delete s[E.id]}function p(){for(const T in i)r.deleteBuffer(i[T]);a=[],i={},s={}}return{bind:l,update:c,dispose:p}}class Wx{constructor(e={}){const{canvas:t=bm(),context:n=null,depth:i=!0,stencil:s=!1,alpha:a=!1,antialias:o=!1,premultipliedAlpha:l=!0,preserveDrawingBuffer:c=!1,powerPreference:u="default",failIfMajorPerformanceCaveat:h=!1,reverseDepthBuffer:d=!1}=e;this.isWebGLRenderer=!0;let f;if(n!==null){if(typeof WebGLRenderingContext<"u"&&n instanceof WebGLRenderingContext)throw new Error("THREE.WebGLRenderer: WebGL 1 is not supported since r163.");f=n.getContextAttributes().alpha}else f=a;const g=new Uint32Array(4),_=new Int32Array(4);let m=null,p=null;const T=[],E=[];this.domElement=t,this.debug={checkShaderErrors:!0,onShaderError:null},this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this._outputColorSpace=jn,this.toneMapping=ir,this.toneMappingExposure=1;const x=this;let R=!1,w=0,b=0,C=null,M=-1,v=null;const P=new Nt,U=new Nt;let O=null;const G=new nt(0);let Y=0,H=t.width,q=t.height,k=1,ne=null,D=null;const ue=new Nt(0,0,H,q),Ie=new Nt(0,0,H,q);let $e=!1;const K=new rd;let te=!1,_e=!1;const ie=new Lt,Ee=new Lt,we=new X,He=new Nt,Ke={background:null,fog:null,environment:null,overrideMaterial:null,isScene:!0};let Fe=!1;function Ce(){return C===null?k:1}let I=n;function mt(y,N){return t.getContext(y,N)}try{const y={alpha:!0,depth:i,stencil:s,antialias:o,premultipliedAlpha:l,preserveDrawingBuffer:c,powerPreference:u,failIfMajorPerformanceCaveat:h};if("setAttribute"in t&&t.setAttribute("data-engine",`three.js r${pu}`),t.addEventListener("webglcontextlost",j,!1),t.addEventListener("webglcontextrestored",le,!1),t.addEventListener("webglcontextcreationerror",he,!1),I===null){const N="webgl2";if(I=mt(N,y),I===null)throw mt(N)?new Error("Error creating WebGL context with your selected attributes."):new Error("Error creating WebGL context.")}}catch(y){throw console.error("THREE.WebGLRenderer: "+y.message),y}let Be,B,Me,rt,Te,A,S,z,Q,J,Z,fe,ae,de,Ge,re,se,Le,Pe,ve,We,Oe,ot,L;function ce(){Be=new Q0(I),Be.init(),Oe=new Nx(I,Be),B=new Y0(I,Be,e,Oe),Me=new Ix(I,Be),B.reverseDepthBuffer&&d&&Me.buffers.depth.setReversed(!0),rt=new nv(I),Te=new Mx,A=new Ux(I,Be,Me,Te,B,Oe,rt),S=new K0(x),z=new J0(x),Q=new c_(I),ot=new X0(I,Q),J=new ev(I,Q,rt,ot),Z=new rv(I,J,Q,rt),Pe=new iv(I,B,A),re=new $0(Te),fe=new xx(x,S,z,Be,B,ot,re),ae=new Vx(x,Te),de=new yx,Ge=new Rx(Be),Le=new W0(x,S,z,Me,Z,f,l),se=new Dx(x,Z,B),L=new Gx(I,rt,B,Me),ve=new q0(I,Be,rt),We=new tv(I,Be,rt),rt.programs=fe.programs,x.capabilities=B,x.extensions=Be,x.properties=Te,x.renderLists=de,x.shadowMap=se,x.state=Me,x.info=rt}ce();const $=new kx(x,I);this.xr=$,this.getContext=function(){return I},this.getContextAttributes=function(){return I.getContextAttributes()},this.forceContextLoss=function(){const y=Be.get("WEBGL_lose_context");y&&y.loseContext()},this.forceContextRestore=function(){const y=Be.get("WEBGL_lose_context");y&&y.restoreContext()},this.getPixelRatio=function(){return k},this.setPixelRatio=function(y){y!==void 0&&(k=y,this.setSize(H,q,!1))},this.getSize=function(y){return y.set(H,q)},this.setSize=function(y,N,V=!0){if($.isPresenting){console.warn("THREE.WebGLRenderer: Can't change size while VR device is presenting.");return}H=y,q=N,t.width=Math.floor(y*k),t.height=Math.floor(N*k),V===!0&&(t.style.width=y+"px",t.style.height=N+"px"),this.setViewport(0,0,y,N)},this.getDrawingBufferSize=function(y){return y.set(H*k,q*k).floor()},this.setDrawingBufferSize=function(y,N,V){H=y,q=N,k=V,t.width=Math.floor(y*V),t.height=Math.floor(N*V),this.setViewport(0,0,y,N)},this.getCurrentViewport=function(y){return y.copy(P)},this.getViewport=function(y){return y.copy(ue)},this.setViewport=function(y,N,V,W){y.isVector4?ue.set(y.x,y.y,y.z,y.w):ue.set(y,N,V,W),Me.viewport(P.copy(ue).multiplyScalar(k).round())},this.getScissor=function(y){return y.copy(Ie)},this.setScissor=function(y,N,V,W){y.isVector4?Ie.set(y.x,y.y,y.z,y.w):Ie.set(y,N,V,W),Me.scissor(U.copy(Ie).multiplyScalar(k).round())},this.getScissorTest=function(){return $e},this.setScissorTest=function(y){Me.setScissorTest($e=y)},this.setOpaqueSort=function(y){ne=y},this.setTransparentSort=function(y){D=y},this.getClearColor=function(y){return y.copy(Le.getClearColor())},this.setClearColor=function(){Le.setClearColor.apply(Le,arguments)},this.getClearAlpha=function(){return Le.getClearAlpha()},this.setClearAlpha=function(){Le.setClearAlpha.apply(Le,arguments)},this.clear=function(y=!0,N=!0,V=!0){let W=0;if(y){let F=!1;if(C!==null){const ee=C.texture.format;F=ee===Mu||ee===xu||ee===vu}if(F){const ee=C.texture.type,oe=ee===zi||ee===Hr||ee===Sa||ee===Ps||ee===_u||ee===gu,xe=Le.getClearColor(),ye=Le.getClearAlpha(),Ue=xe.r,De=xe.g,Re=xe.b;oe?(g[0]=Ue,g[1]=De,g[2]=Re,g[3]=ye,I.clearBufferuiv(I.COLOR,0,g)):(_[0]=Ue,_[1]=De,_[2]=Re,_[3]=ye,I.clearBufferiv(I.COLOR,0,_))}else W|=I.COLOR_BUFFER_BIT}N&&(W|=I.DEPTH_BUFFER_BIT),V&&(W|=I.STENCIL_BUFFER_BIT,this.state.buffers.stencil.setMask(4294967295)),I.clear(W)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.dispose=function(){t.removeEventListener("webglcontextlost",j,!1),t.removeEventListener("webglcontextrestored",le,!1),t.removeEventListener("webglcontextcreationerror",he,!1),Le.dispose(),de.dispose(),Ge.dispose(),Te.dispose(),S.dispose(),z.dispose(),Z.dispose(),ot.dispose(),L.dispose(),fe.dispose(),$.dispose(),$.removeEventListener("sessionstart",pe),$.removeEventListener("sessionend",Ve),Ae.stop()};function j(y){y.preventDefault(),console.log("THREE.WebGLRenderer: Context Lost."),R=!0}function le(){console.log("THREE.WebGLRenderer: Context Restored."),R=!1;const y=rt.autoReset,N=se.enabled,V=se.autoUpdate,W=se.needsUpdate,F=se.type;ce(),rt.autoReset=y,se.enabled=N,se.autoUpdate=V,se.needsUpdate=W,se.type=F}function he(y){console.error("THREE.WebGLRenderer: A WebGL context could not be created. Reason: ",y.statusMessage)}function ze(y){const N=y.target;N.removeEventListener("dispose",ze),lt(N)}function lt(y){Ct(y),Te.remove(y)}function Ct(y){const N=Te.get(y).programs;N!==void 0&&(N.forEach(function(V){fe.releaseProgram(V)}),y.isShaderMaterial&&fe.releaseShaderCache(y))}this.renderBufferDirect=function(y,N,V,W,F,ee){N===null&&(N=Ke);const oe=F.isMesh&&F.matrixWorld.determinant()<0,xe=Dn(y,N,V,W,F);Me.setMaterial(W,oe);let ye=V.index,Ue=1;if(W.wireframe===!0){if(ye=J.getWireframeAttribute(V),ye===void 0)return;Ue=2}const De=V.drawRange,Re=V.attributes.position;let Qe=De.start*Ue,Ze=(De.start+De.count)*Ue;ee!==null&&(Qe=Math.max(Qe,ee.start*Ue),Ze=Math.min(Ze,(ee.start+ee.count)*Ue)),ye!==null?(Qe=Math.max(Qe,0),Ze=Math.min(Ze,ye.count)):Re!=null&&(Qe=Math.max(Qe,0),Ze=Math.min(Ze,Re.count));const Ot=Ze-Qe;if(Ot<0||Ot===1/0)return;ot.setup(F,W,xe,V,ye);let Pt,ct=ve;if(ye!==null&&(Pt=Q.get(ye),ct=We,ct.setIndex(Pt)),F.isMesh)W.wireframe===!0?(Me.setLineWidth(W.wireframeLinewidth*Ce()),ct.setMode(I.LINES)):ct.setMode(I.TRIANGLES);else if(F.isLine){let Ne=W.linewidth;Ne===void 0&&(Ne=1),Me.setLineWidth(Ne*Ce()),F.isLineSegments?ct.setMode(I.LINES):F.isLineLoop?ct.setMode(I.LINE_LOOP):ct.setMode(I.LINE_STRIP)}else F.isPoints?ct.setMode(I.POINTS):F.isSprite&&ct.setMode(I.TRIANGLES);if(F.isBatchedMesh)if(F._multiDrawInstances!==null)ct.renderMultiDrawInstances(F._multiDrawStarts,F._multiDrawCounts,F._multiDrawCount,F._multiDrawInstances);else if(Be.get("WEBGL_multi_draw"))ct.renderMultiDraw(F._multiDrawStarts,F._multiDrawCounts,F._multiDrawCount);else{const Ne=F._multiDrawStarts,Jt=F._multiDrawCounts,ht=F._multiDrawCount,ri=ye?Q.get(ye).bytesPerElement:1,Yr=Te.get(W).currentProgram.getUniforms();for(let Ln=0;Ln<ht;Ln++)Yr.setValue(I,"_gl_DrawID",Ln),ct.render(Ne[Ln]/ri,Jt[Ln])}else if(F.isInstancedMesh)ct.renderInstances(Qe,Ot,F.count);else if(V.isInstancedBufferGeometry){const Ne=V._maxInstanceCount!==void 0?V._maxInstanceCount:1/0,Jt=Math.min(V.instanceCount,Ne);ct.renderInstances(Qe,Ot,Jt)}else ct.render(Qe,Ot)};function ge(y,N,V){y.transparent===!0&&y.side===Pi&&y.forceSinglePass===!1?(y.side=Tn,y.needsUpdate=!0,_t(y,N,V),y.side=or,y.needsUpdate=!0,_t(y,N,V),y.side=Pi):_t(y,N,V)}this.compile=function(y,N,V=null){V===null&&(V=y),p=Ge.get(V),p.init(N),E.push(p),V.traverseVisible(function(F){F.isLight&&F.layers.test(N.layers)&&(p.pushLight(F),F.castShadow&&p.pushShadow(F))}),y!==V&&y.traverseVisible(function(F){F.isLight&&F.layers.test(N.layers)&&(p.pushLight(F),F.castShadow&&p.pushShadow(F))}),p.setupLights();const W=new Set;return y.traverse(function(F){if(!(F.isMesh||F.isPoints||F.isLine||F.isSprite))return;const ee=F.material;if(ee)if(Array.isArray(ee))for(let oe=0;oe<ee.length;oe++){const xe=ee[oe];ge(xe,V,F),W.add(xe)}else ge(ee,V,F),W.add(ee)}),E.pop(),p=null,W},this.compileAsync=function(y,N,V=null){const W=this.compile(y,N,V);return new Promise(F=>{function ee(){if(W.forEach(function(oe){Te.get(oe).currentProgram.isReady()&&W.delete(oe)}),W.size===0){F(y);return}setTimeout(ee,10)}Be.get("KHR_parallel_shader_compile")!==null?ee():setTimeout(ee,10)})};let be=null;function Xe(y){be&&be(y)}function pe(){Ae.stop()}function Ve(){Ae.start()}const Ae=new ld;Ae.setAnimationLoop(Xe),typeof self<"u"&&Ae.setContext(self),this.setAnimationLoop=function(y){be=y,$.setAnimationLoop(y),y===null?Ae.stop():Ae.start()},$.addEventListener("sessionstart",pe),$.addEventListener("sessionend",Ve),this.render=function(y,N){if(N!==void 0&&N.isCamera!==!0){console.error("THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(R===!0)return;if(y.matrixWorldAutoUpdate===!0&&y.updateMatrixWorld(),N.parent===null&&N.matrixWorldAutoUpdate===!0&&N.updateMatrixWorld(),$.enabled===!0&&$.isPresenting===!0&&($.cameraAutoUpdate===!0&&$.updateCamera(N),N=$.getCamera()),y.isScene===!0&&y.onBeforeRender(x,y,N,C),p=Ge.get(y,E.length),p.init(N),E.push(p),Ee.multiplyMatrices(N.projectionMatrix,N.matrixWorldInverse),K.setFromProjectionMatrix(Ee),_e=this.localClippingEnabled,te=re.init(this.clippingPlanes,_e),m=de.get(y,T.length),m.init(),T.push(m),$.enabled===!0&&$.isPresenting===!0){const ee=x.xr.getDepthSensingMesh();ee!==null&&ke(ee,N,-1/0,x.sortObjects)}ke(y,N,0,x.sortObjects),m.finish(),x.sortObjects===!0&&m.sort(ne,D),Fe=$.enabled===!1||$.isPresenting===!1||$.hasDepthSensing()===!1,Fe&&Le.addToRenderList(m,y),this.info.render.frame++,te===!0&&re.beginShadows();const V=p.state.shadowsArray;se.render(V,y,N),te===!0&&re.endShadows(),this.info.autoReset===!0&&this.info.reset();const W=m.opaque,F=m.transmissive;if(p.setupLights(),N.isArrayCamera){const ee=N.cameras;if(F.length>0)for(let oe=0,xe=ee.length;oe<xe;oe++){const ye=ee[oe];Je(W,F,y,ye)}Fe&&Le.render(y);for(let oe=0,xe=ee.length;oe<xe;oe++){const ye=ee[oe];It(m,y,ye,ye.viewport)}}else F.length>0&&Je(W,F,y,N),Fe&&Le.render(y),It(m,y,N);C!==null&&(A.updateMultisampleRenderTarget(C),A.updateRenderTargetMipmap(C)),y.isScene===!0&&y.onAfterRender(x,y,N),ot.resetDefaultState(),M=-1,v=null,E.pop(),E.length>0?(p=E[E.length-1],te===!0&&re.setGlobalState(x.clippingPlanes,p.state.camera)):p=null,T.pop(),T.length>0?m=T[T.length-1]:m=null};function ke(y,N,V,W){if(y.visible===!1)return;if(y.layers.test(N.layers)){if(y.isGroup)V=y.renderOrder;else if(y.isLOD)y.autoUpdate===!0&&y.update(N);else if(y.isLight)p.pushLight(y),y.castShadow&&p.pushShadow(y);else if(y.isSprite){if(!y.frustumCulled||K.intersectsSprite(y)){W&&He.setFromMatrixPosition(y.matrixWorld).applyMatrix4(Ee);const oe=Z.update(y),xe=y.material;xe.visible&&m.push(y,oe,xe,V,He.z,null)}}else if((y.isMesh||y.isLine||y.isPoints)&&(!y.frustumCulled||K.intersectsObject(y))){const oe=Z.update(y),xe=y.material;if(W&&(y.boundingSphere!==void 0?(y.boundingSphere===null&&y.computeBoundingSphere(),He.copy(y.boundingSphere.center)):(oe.boundingSphere===null&&oe.computeBoundingSphere(),He.copy(oe.boundingSphere.center)),He.applyMatrix4(y.matrixWorld).applyMatrix4(Ee)),Array.isArray(xe)){const ye=oe.groups;for(let Ue=0,De=ye.length;Ue<De;Ue++){const Re=ye[Ue],Qe=xe[Re.materialIndex];Qe&&Qe.visible&&m.push(y,oe,Qe,V,He.z,Re)}}else xe.visible&&m.push(y,oe,xe,V,He.z,null)}}const ee=y.children;for(let oe=0,xe=ee.length;oe<xe;oe++)ke(ee[oe],N,V,W)}function It(y,N,V,W){const F=y.opaque,ee=y.transmissive,oe=y.transparent;p.setupLightsView(V),te===!0&&re.setGlobalState(x.clippingPlanes,V),W&&Me.viewport(P.copy(W)),F.length>0&&St(F,N,V),ee.length>0&&St(ee,N,V),oe.length>0&&St(oe,N,V),Me.buffers.depth.setTest(!0),Me.buffers.depth.setMask(!0),Me.buffers.color.setMask(!0),Me.setPolygonOffset(!1)}function Je(y,N,V,W){if((V.isScene===!0?V.overrideMaterial:null)!==null)return;p.state.transmissionRenderTarget[W.id]===void 0&&(p.state.transmissionRenderTarget[W.id]=new Vr(1,1,{generateMipmaps:!0,type:Be.has("EXT_color_buffer_half_float")||Be.has("EXT_color_buffer_float")?Da:zi,minFilter:Dr,samples:4,stencilBuffer:s,resolveDepthBuffer:!1,resolveStencilBuffer:!1,colorSpace:ut.workingColorSpace}));const ee=p.state.transmissionRenderTarget[W.id],oe=W.viewport||P;ee.setSize(oe.z,oe.w);const xe=x.getRenderTarget();x.setRenderTarget(ee),x.getClearColor(G),Y=x.getClearAlpha(),Y<1&&x.setClearColor(16777215,.5),x.clear(),Fe&&Le.render(V);const ye=x.toneMapping;x.toneMapping=ir;const Ue=W.viewport;if(W.viewport!==void 0&&(W.viewport=void 0),p.setupLightsView(W),te===!0&&re.setGlobalState(x.clippingPlanes,W),St(y,V,W),A.updateMultisampleRenderTarget(ee),A.updateRenderTargetMipmap(ee),Be.has("WEBGL_multisampled_render_to_texture")===!1){let De=!1;for(let Re=0,Qe=N.length;Re<Qe;Re++){const Ze=N[Re],Ot=Ze.object,Pt=Ze.geometry,ct=Ze.material,Ne=Ze.group;if(ct.side===Pi&&Ot.layers.test(W.layers)){const Jt=ct.side;ct.side=Tn,ct.needsUpdate=!0,Vt(Ot,V,W,Pt,ct,Ne),ct.side=Jt,ct.needsUpdate=!0,De=!0}}De===!0&&(A.updateMultisampleRenderTarget(ee),A.updateRenderTargetMipmap(ee))}x.setRenderTarget(xe),x.setClearColor(G,Y),Ue!==void 0&&(W.viewport=Ue),x.toneMapping=ye}function St(y,N,V){const W=N.isScene===!0?N.overrideMaterial:null;for(let F=0,ee=y.length;F<ee;F++){const oe=y[F],xe=oe.object,ye=oe.geometry,Ue=W===null?oe.material:W,De=oe.group;xe.layers.test(V.layers)&&Vt(xe,N,V,ye,Ue,De)}}function Vt(y,N,V,W,F,ee){y.onBeforeRender(x,N,V,W,F,ee),y.modelViewMatrix.multiplyMatrices(V.matrixWorldInverse,y.matrixWorld),y.normalMatrix.getNormalMatrix(y.modelViewMatrix),F.onBeforeRender(x,N,V,W,y,ee),F.transparent===!0&&F.side===Pi&&F.forceSinglePass===!1?(F.side=Tn,F.needsUpdate=!0,x.renderBufferDirect(V,N,W,F,y,ee),F.side=or,F.needsUpdate=!0,x.renderBufferDirect(V,N,W,F,y,ee),F.side=Pi):x.renderBufferDirect(V,N,W,F,y,ee),y.onAfterRender(x,N,V,W,F,ee)}function _t(y,N,V){N.isScene!==!0&&(N=Ke);const W=Te.get(y),F=p.state.lights,ee=p.state.shadowsArray,oe=F.state.version,xe=fe.getParameters(y,F.state,ee,N,V),ye=fe.getProgramCacheKey(xe);let Ue=W.programs;W.environment=y.isMeshStandardMaterial?N.environment:null,W.fog=N.fog,W.envMap=(y.isMeshStandardMaterial?z:S).get(y.envMap||W.environment),W.envMapRotation=W.environment!==null&&y.envMap===null?N.environmentRotation:y.envMapRotation,Ue===void 0&&(y.addEventListener("dispose",ze),Ue=new Map,W.programs=Ue);let De=Ue.get(ye);if(De!==void 0){if(W.currentProgram===De&&W.lightsStateVersion===oe)return ft(y,xe),De}else xe.uniforms=fe.getUniforms(y),y.onBeforeCompile(xe,x),De=fe.acquireProgram(xe,ye),Ue.set(ye,De),W.uniforms=xe.uniforms;const Re=W.uniforms;return(!y.isShaderMaterial&&!y.isRawShaderMaterial||y.clipping===!0)&&(Re.clippingPlanes=re.uniform),ft(y,xe),W.needsLights=cn(y),W.lightsStateVersion=oe,W.needsLights&&(Re.ambientLightColor.value=F.state.ambient,Re.lightProbe.value=F.state.probe,Re.directionalLights.value=F.state.directional,Re.directionalLightShadows.value=F.state.directionalShadow,Re.spotLights.value=F.state.spot,Re.spotLightShadows.value=F.state.spotShadow,Re.rectAreaLights.value=F.state.rectArea,Re.ltc_1.value=F.state.rectAreaLTC1,Re.ltc_2.value=F.state.rectAreaLTC2,Re.pointLights.value=F.state.point,Re.pointLightShadows.value=F.state.pointShadow,Re.hemisphereLights.value=F.state.hemi,Re.directionalShadowMap.value=F.state.directionalShadowMap,Re.directionalShadowMatrix.value=F.state.directionalShadowMatrix,Re.spotShadowMap.value=F.state.spotShadowMap,Re.spotLightMatrix.value=F.state.spotLightMatrix,Re.spotLightMap.value=F.state.spotLightMap,Re.pointShadowMap.value=F.state.pointShadowMap,Re.pointShadowMatrix.value=F.state.pointShadowMatrix),W.currentProgram=De,W.uniformsList=null,De}function gt(y){if(y.uniformsList===null){const N=y.currentProgram.getUniforms();y.uniformsList=Co.seqWithValue(N.seq,y.uniforms)}return y.uniformsList}function ft(y,N){const V=Te.get(y);V.outputColorSpace=N.outputColorSpace,V.batching=N.batching,V.batchingColor=N.batchingColor,V.instancing=N.instancing,V.instancingColor=N.instancingColor,V.instancingMorph=N.instancingMorph,V.skinning=N.skinning,V.morphTargets=N.morphTargets,V.morphNormals=N.morphNormals,V.morphColors=N.morphColors,V.morphTargetsCount=N.morphTargetsCount,V.numClippingPlanes=N.numClippingPlanes,V.numIntersection=N.numClipIntersection,V.vertexAlphas=N.vertexAlphas,V.vertexTangents=N.vertexTangents,V.toneMapping=N.toneMapping}function Dn(y,N,V,W,F){N.isScene!==!0&&(N=Ke),A.resetTextureUnits();const ee=N.fog,oe=W.isMeshStandardMaterial?N.environment:null,xe=C===null?x.outputColorSpace:C.isXRRenderTarget===!0?C.texture.colorSpace:Ls,ye=(W.isMeshStandardMaterial?z:S).get(W.envMap||oe),Ue=W.vertexColors===!0&&!!V.attributes.color&&V.attributes.color.itemSize===4,De=!!V.attributes.tangent&&(!!W.normalMap||W.anisotropy>0),Re=!!V.morphAttributes.position,Qe=!!V.morphAttributes.normal,Ze=!!V.morphAttributes.color;let Ot=ir;W.toneMapped&&(C===null||C.isXRRenderTarget===!0)&&(Ot=x.toneMapping);const Pt=V.morphAttributes.position||V.morphAttributes.normal||V.morphAttributes.color,ct=Pt!==void 0?Pt.length:0,Ne=Te.get(W),Jt=p.state.lights;if(te===!0&&(_e===!0||y!==v)){const un=y===v&&W.id===M;re.setState(W,y,un)}let ht=!1;W.version===Ne.__version?(Ne.needsLights&&Ne.lightsStateVersion!==Jt.state.version||Ne.outputColorSpace!==xe||F.isBatchedMesh&&Ne.batching===!1||!F.isBatchedMesh&&Ne.batching===!0||F.isBatchedMesh&&Ne.batchingColor===!0&&F.colorTexture===null||F.isBatchedMesh&&Ne.batchingColor===!1&&F.colorTexture!==null||F.isInstancedMesh&&Ne.instancing===!1||!F.isInstancedMesh&&Ne.instancing===!0||F.isSkinnedMesh&&Ne.skinning===!1||!F.isSkinnedMesh&&Ne.skinning===!0||F.isInstancedMesh&&Ne.instancingColor===!0&&F.instanceColor===null||F.isInstancedMesh&&Ne.instancingColor===!1&&F.instanceColor!==null||F.isInstancedMesh&&Ne.instancingMorph===!0&&F.morphTexture===null||F.isInstancedMesh&&Ne.instancingMorph===!1&&F.morphTexture!==null||Ne.envMap!==ye||W.fog===!0&&Ne.fog!==ee||Ne.numClippingPlanes!==void 0&&(Ne.numClippingPlanes!==re.numPlanes||Ne.numIntersection!==re.numIntersection)||Ne.vertexAlphas!==Ue||Ne.vertexTangents!==De||Ne.morphTargets!==Re||Ne.morphNormals!==Qe||Ne.morphColors!==Ze||Ne.toneMapping!==Ot||Ne.morphTargetsCount!==ct)&&(ht=!0):(ht=!0,Ne.__version=W.version);let ri=Ne.currentProgram;ht===!0&&(ri=_t(W,N,F));let Yr=!1,Ln=!1,Ws=!1;const Tt=ri.getUniforms(),Yn=Ne.uniforms;if(Me.useProgram(ri.program)&&(Yr=!0,Ln=!0,Ws=!0),W.id!==M&&(M=W.id,Ln=!0),Yr||v!==y){Me.buffers.depth.getReversed()?(ie.copy(y.projectionMatrix),wm(ie),Rm(ie),Tt.setValue(I,"projectionMatrix",ie)):Tt.setValue(I,"projectionMatrix",y.projectionMatrix),Tt.setValue(I,"viewMatrix",y.matrixWorldInverse);const Mn=Tt.map.cameraPosition;Mn!==void 0&&Mn.setValue(I,we.setFromMatrixPosition(y.matrixWorld)),B.logarithmicDepthBuffer&&Tt.setValue(I,"logDepthBufFC",2/(Math.log(y.far+1)/Math.LN2)),(W.isMeshPhongMaterial||W.isMeshToonMaterial||W.isMeshLambertMaterial||W.isMeshBasicMaterial||W.isMeshStandardMaterial||W.isShaderMaterial)&&Tt.setValue(I,"isOrthographic",y.isOrthographicCamera===!0),v!==y&&(v=y,Ln=!0,Ws=!0)}if(F.isSkinnedMesh){Tt.setOptional(I,F,"bindMatrix"),Tt.setOptional(I,F,"bindMatrixInverse");const un=F.skeleton;un&&(un.boneTexture===null&&un.computeBoneTexture(),Tt.setValue(I,"boneTexture",un.boneTexture,A))}F.isBatchedMesh&&(Tt.setOptional(I,F,"batchingTexture"),Tt.setValue(I,"batchingTexture",F._matricesTexture,A),Tt.setOptional(I,F,"batchingIdTexture"),Tt.setValue(I,"batchingIdTexture",F._indirectTexture,A),Tt.setOptional(I,F,"batchingColorTexture"),F._colorsTexture!==null&&Tt.setValue(I,"batchingColorTexture",F._colorsTexture,A));const $n=V.morphAttributes;if(($n.position!==void 0||$n.normal!==void 0||$n.color!==void 0)&&Pe.update(F,V,ri),(Ln||Ne.receiveShadow!==F.receiveShadow)&&(Ne.receiveShadow=F.receiveShadow,Tt.setValue(I,"receiveShadow",F.receiveShadow)),W.isMeshGouraudMaterial&&W.envMap!==null&&(Yn.envMap.value=ye,Yn.flipEnvMap.value=ye.isCubeTexture&&ye.isRenderTargetTexture===!1?-1:1),W.isMeshStandardMaterial&&W.envMap===null&&N.environment!==null&&(Yn.envMapIntensity.value=N.environmentIntensity),Ln&&(Tt.setValue(I,"toneMappingExposure",x.toneMappingExposure),Ne.needsLights&&Et(Yn,Ws),ee&&W.fog===!0&&ae.refreshFogUniforms(Yn,ee),ae.refreshMaterialUniforms(Yn,W,k,q,p.state.transmissionRenderTarget[y.id]),Co.upload(I,gt(Ne),Yn,A)),W.isShaderMaterial&&W.uniformsNeedUpdate===!0&&(Co.upload(I,gt(Ne),Yn,A),W.uniformsNeedUpdate=!1),W.isSpriteMaterial&&Tt.setValue(I,"center",F.center),Tt.setValue(I,"modelViewMatrix",F.modelViewMatrix),Tt.setValue(I,"normalMatrix",F.normalMatrix),Tt.setValue(I,"modelMatrix",F.matrixWorld),W.isShaderMaterial||W.isRawShaderMaterial){const un=W.uniformsGroups;for(let Mn=0,cl=un.length;Mn<cl;Mn++){const pr=un[Mn];L.update(pr,ri),L.bind(pr,ri)}}return ri}function Et(y,N){y.ambientLightColor.needsUpdate=N,y.lightProbe.needsUpdate=N,y.directionalLights.needsUpdate=N,y.directionalLightShadows.needsUpdate=N,y.pointLights.needsUpdate=N,y.pointLightShadows.needsUpdate=N,y.spotLights.needsUpdate=N,y.spotLightShadows.needsUpdate=N,y.rectAreaLights.needsUpdate=N,y.hemisphereLights.needsUpdate=N}function cn(y){return y.isMeshLambertMaterial||y.isMeshToonMaterial||y.isMeshPhongMaterial||y.isMeshStandardMaterial||y.isShadowMaterial||y.isShaderMaterial&&y.lights===!0}this.getActiveCubeFace=function(){return w},this.getActiveMipmapLevel=function(){return b},this.getRenderTarget=function(){return C},this.setRenderTargetTextures=function(y,N,V){Te.get(y.texture).__webglTexture=N,Te.get(y.depthTexture).__webglTexture=V;const W=Te.get(y);W.__hasExternalTextures=!0,W.__autoAllocateDepthBuffer=V===void 0,W.__autoAllocateDepthBuffer||Be.has("WEBGL_multisampled_render_to_texture")===!0&&(console.warn("THREE.WebGLRenderer: Render-to-texture extension was disabled because an external texture was provided"),W.__useRenderToTexture=!1)},this.setRenderTargetFramebuffer=function(y,N){const V=Te.get(y);V.__webglFramebuffer=N,V.__useDefaultFramebuffer=N===void 0},this.setRenderTarget=function(y,N=0,V=0){C=y,w=N,b=V;let W=!0,F=null,ee=!1,oe=!1;if(y){const ye=Te.get(y);if(ye.__useDefaultFramebuffer!==void 0)Me.bindFramebuffer(I.FRAMEBUFFER,null),W=!1;else if(ye.__webglFramebuffer===void 0)A.setupRenderTarget(y);else if(ye.__hasExternalTextures)A.rebindTextures(y,Te.get(y.texture).__webglTexture,Te.get(y.depthTexture).__webglTexture);else if(y.depthBuffer){const Re=y.depthTexture;if(ye.__boundDepthTexture!==Re){if(Re!==null&&Te.has(Re)&&(y.width!==Re.image.width||y.height!==Re.image.height))throw new Error("WebGLRenderTarget: Attached DepthTexture is initialized to the incorrect size.");A.setupDepthRenderbuffer(y)}}const Ue=y.texture;(Ue.isData3DTexture||Ue.isDataArrayTexture||Ue.isCompressedArrayTexture)&&(oe=!0);const De=Te.get(y).__webglFramebuffer;y.isWebGLCubeRenderTarget?(Array.isArray(De[N])?F=De[N][V]:F=De[N],ee=!0):y.samples>0&&A.useMultisampledRTT(y)===!1?F=Te.get(y).__webglMultisampledFramebuffer:Array.isArray(De)?F=De[V]:F=De,P.copy(y.viewport),U.copy(y.scissor),O=y.scissorTest}else P.copy(ue).multiplyScalar(k).floor(),U.copy(Ie).multiplyScalar(k).floor(),O=$e;if(Me.bindFramebuffer(I.FRAMEBUFFER,F)&&W&&Me.drawBuffers(y,F),Me.viewport(P),Me.scissor(U),Me.setScissorTest(O),ee){const ye=Te.get(y.texture);I.framebufferTexture2D(I.FRAMEBUFFER,I.COLOR_ATTACHMENT0,I.TEXTURE_CUBE_MAP_POSITIVE_X+N,ye.__webglTexture,V)}else if(oe){const ye=Te.get(y.texture),Ue=N||0;I.framebufferTextureLayer(I.FRAMEBUFFER,I.COLOR_ATTACHMENT0,ye.__webglTexture,V||0,Ue)}M=-1},this.readRenderTargetPixels=function(y,N,V,W,F,ee,oe){if(!(y&&y.isWebGLRenderTarget)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}let xe=Te.get(y).__webglFramebuffer;if(y.isWebGLCubeRenderTarget&&oe!==void 0&&(xe=xe[oe]),xe){Me.bindFramebuffer(I.FRAMEBUFFER,xe);try{const ye=y.texture,Ue=ye.format,De=ye.type;if(!B.textureFormatReadable(Ue)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}if(!B.textureTypeReadable(De)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}N>=0&&N<=y.width-W&&V>=0&&V<=y.height-F&&I.readPixels(N,V,W,F,Oe.convert(Ue),Oe.convert(De),ee)}finally{const ye=C!==null?Te.get(C).__webglFramebuffer:null;Me.bindFramebuffer(I.FRAMEBUFFER,ye)}}},this.readRenderTargetPixelsAsync=async function(y,N,V,W,F,ee,oe){if(!(y&&y.isWebGLRenderTarget))throw new Error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");let xe=Te.get(y).__webglFramebuffer;if(y.isWebGLCubeRenderTarget&&oe!==void 0&&(xe=xe[oe]),xe){const ye=y.texture,Ue=ye.format,De=ye.type;if(!B.textureFormatReadable(Ue))throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in RGBA or implementation defined format.");if(!B.textureTypeReadable(De))throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in UnsignedByteType or implementation defined type.");if(N>=0&&N<=y.width-W&&V>=0&&V<=y.height-F){Me.bindFramebuffer(I.FRAMEBUFFER,xe);const Re=I.createBuffer();I.bindBuffer(I.PIXEL_PACK_BUFFER,Re),I.bufferData(I.PIXEL_PACK_BUFFER,ee.byteLength,I.STREAM_READ),I.readPixels(N,V,W,F,Oe.convert(Ue),Oe.convert(De),0);const Qe=C!==null?Te.get(C).__webglFramebuffer:null;Me.bindFramebuffer(I.FRAMEBUFFER,Qe);const Ze=I.fenceSync(I.SYNC_GPU_COMMANDS_COMPLETE,0);return I.flush(),await Am(I,Ze,4),I.bindBuffer(I.PIXEL_PACK_BUFFER,Re),I.getBufferSubData(I.PIXEL_PACK_BUFFER,0,ee),I.deleteBuffer(Re),I.deleteSync(Ze),ee}else throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: requested read bounds are out of range.")}},this.copyFramebufferToTexture=function(y,N=null,V=0){y.isTexture!==!0&&(fs("WebGLRenderer: copyFramebufferToTexture function signature has changed."),N=arguments[0]||null,y=arguments[1]);const W=Math.pow(2,-V),F=Math.floor(y.image.width*W),ee=Math.floor(y.image.height*W),oe=N!==null?N.x:0,xe=N!==null?N.y:0;A.setTexture2D(y,0),I.copyTexSubImage2D(I.TEXTURE_2D,V,0,0,oe,xe,F,ee),Me.unbindTexture()};const qn=I.createFramebuffer(),Gt=I.createFramebuffer();this.copyTextureToTexture=function(y,N,V=null,W=null,F=0,ee=null){y.isTexture!==!0&&(fs("WebGLRenderer: copyTextureToTexture function signature has changed."),W=arguments[0]||null,y=arguments[1],N=arguments[2],ee=arguments[3]||0,V=null),ee===null&&(F!==0?(fs("WebGLRenderer: copyTextureToTexture function signature has changed to support src and dst mipmap levels."),ee=F,F=0):ee=0);let oe,xe,ye,Ue,De,Re,Qe,Ze,Ot;const Pt=y.isCompressedTexture?y.mipmaps[ee]:y.image;if(V!==null)oe=V.max.x-V.min.x,xe=V.max.y-V.min.y,ye=V.isBox3?V.max.z-V.min.z:1,Ue=V.min.x,De=V.min.y,Re=V.isBox3?V.min.z:0;else{const $n=Math.pow(2,-F);oe=Math.floor(Pt.width*$n),xe=Math.floor(Pt.height*$n),y.isDataArrayTexture?ye=Pt.depth:y.isData3DTexture?ye=Math.floor(Pt.depth*$n):ye=1,Ue=0,De=0,Re=0}W!==null?(Qe=W.x,Ze=W.y,Ot=W.z):(Qe=0,Ze=0,Ot=0);const ct=Oe.convert(N.format),Ne=Oe.convert(N.type);let Jt;N.isData3DTexture?(A.setTexture3D(N,0),Jt=I.TEXTURE_3D):N.isDataArrayTexture||N.isCompressedArrayTexture?(A.setTexture2DArray(N,0),Jt=I.TEXTURE_2D_ARRAY):(A.setTexture2D(N,0),Jt=I.TEXTURE_2D),I.pixelStorei(I.UNPACK_FLIP_Y_WEBGL,N.flipY),I.pixelStorei(I.UNPACK_PREMULTIPLY_ALPHA_WEBGL,N.premultiplyAlpha),I.pixelStorei(I.UNPACK_ALIGNMENT,N.unpackAlignment);const ht=I.getParameter(I.UNPACK_ROW_LENGTH),ri=I.getParameter(I.UNPACK_IMAGE_HEIGHT),Yr=I.getParameter(I.UNPACK_SKIP_PIXELS),Ln=I.getParameter(I.UNPACK_SKIP_ROWS),Ws=I.getParameter(I.UNPACK_SKIP_IMAGES);I.pixelStorei(I.UNPACK_ROW_LENGTH,Pt.width),I.pixelStorei(I.UNPACK_IMAGE_HEIGHT,Pt.height),I.pixelStorei(I.UNPACK_SKIP_PIXELS,Ue),I.pixelStorei(I.UNPACK_SKIP_ROWS,De),I.pixelStorei(I.UNPACK_SKIP_IMAGES,Re);const Tt=y.isDataArrayTexture||y.isData3DTexture,Yn=N.isDataArrayTexture||N.isData3DTexture;if(y.isDepthTexture){const $n=Te.get(y),un=Te.get(N),Mn=Te.get($n.__renderTarget),cl=Te.get(un.__renderTarget);Me.bindFramebuffer(I.READ_FRAMEBUFFER,Mn.__webglFramebuffer),Me.bindFramebuffer(I.DRAW_FRAMEBUFFER,cl.__webglFramebuffer);for(let pr=0;pr<ye;pr++)Tt&&(I.framebufferTextureLayer(I.READ_FRAMEBUFFER,I.COLOR_ATTACHMENT0,Te.get(y).__webglTexture,F,Re+pr),I.framebufferTextureLayer(I.DRAW_FRAMEBUFFER,I.COLOR_ATTACHMENT0,Te.get(N).__webglTexture,ee,Ot+pr)),I.blitFramebuffer(Ue,De,oe,xe,Qe,Ze,oe,xe,I.DEPTH_BUFFER_BIT,I.NEAREST);Me.bindFramebuffer(I.READ_FRAMEBUFFER,null),Me.bindFramebuffer(I.DRAW_FRAMEBUFFER,null)}else if(F!==0||y.isRenderTargetTexture||Te.has(y)){const $n=Te.get(y),un=Te.get(N);Me.bindFramebuffer(I.READ_FRAMEBUFFER,qn),Me.bindFramebuffer(I.DRAW_FRAMEBUFFER,Gt);for(let Mn=0;Mn<ye;Mn++)Tt?I.framebufferTextureLayer(I.READ_FRAMEBUFFER,I.COLOR_ATTACHMENT0,$n.__webglTexture,F,Re+Mn):I.framebufferTexture2D(I.READ_FRAMEBUFFER,I.COLOR_ATTACHMENT0,I.TEXTURE_2D,$n.__webglTexture,F),Yn?I.framebufferTextureLayer(I.DRAW_FRAMEBUFFER,I.COLOR_ATTACHMENT0,un.__webglTexture,ee,Ot+Mn):I.framebufferTexture2D(I.DRAW_FRAMEBUFFER,I.COLOR_ATTACHMENT0,I.TEXTURE_2D,un.__webglTexture,ee),F!==0?I.blitFramebuffer(Ue,De,oe,xe,Qe,Ze,oe,xe,I.COLOR_BUFFER_BIT,I.NEAREST):Yn?I.copyTexSubImage3D(Jt,ee,Qe,Ze,Ot+Mn,Ue,De,oe,xe):I.copyTexSubImage2D(Jt,ee,Qe,Ze,Ue,De,oe,xe);Me.bindFramebuffer(I.READ_FRAMEBUFFER,null),Me.bindFramebuffer(I.DRAW_FRAMEBUFFER,null)}else Yn?y.isDataTexture||y.isData3DTexture?I.texSubImage3D(Jt,ee,Qe,Ze,Ot,oe,xe,ye,ct,Ne,Pt.data):N.isCompressedArrayTexture?I.compressedTexSubImage3D(Jt,ee,Qe,Ze,Ot,oe,xe,ye,ct,Pt.data):I.texSubImage3D(Jt,ee,Qe,Ze,Ot,oe,xe,ye,ct,Ne,Pt):y.isDataTexture?I.texSubImage2D(I.TEXTURE_2D,ee,Qe,Ze,oe,xe,ct,Ne,Pt.data):y.isCompressedTexture?I.compressedTexSubImage2D(I.TEXTURE_2D,ee,Qe,Ze,Pt.width,Pt.height,ct,Pt.data):I.texSubImage2D(I.TEXTURE_2D,ee,Qe,Ze,oe,xe,ct,Ne,Pt);I.pixelStorei(I.UNPACK_ROW_LENGTH,ht),I.pixelStorei(I.UNPACK_IMAGE_HEIGHT,ri),I.pixelStorei(I.UNPACK_SKIP_PIXELS,Yr),I.pixelStorei(I.UNPACK_SKIP_ROWS,Ln),I.pixelStorei(I.UNPACK_SKIP_IMAGES,Ws),ee===0&&N.generateMipmaps&&I.generateMipmap(Jt),Me.unbindTexture()},this.copyTextureToTexture3D=function(y,N,V=null,W=null,F=0){return y.isTexture!==!0&&(fs("WebGLRenderer: copyTextureToTexture3D function signature has changed."),V=arguments[0]||null,W=arguments[1]||null,y=arguments[2],N=arguments[3],F=arguments[4]||0),fs('WebGLRenderer: copyTextureToTexture3D function has been deprecated. Use "copyTextureToTexture" instead.'),this.copyTextureToTexture(y,N,V,W,F)},this.initRenderTarget=function(y){Te.get(y).__webglFramebuffer===void 0&&A.setupRenderTarget(y)},this.initTexture=function(y){y.isCubeTexture?A.setTextureCube(y,0):y.isData3DTexture?A.setTexture3D(y,0):y.isDataArrayTexture||y.isCompressedArrayTexture?A.setTexture2DArray(y,0):A.setTexture2D(y,0),Me.unbindTexture()},this.resetState=function(){w=0,b=0,C=null,Me.reset(),ot.reset()},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}get coordinateSystem(){return Ii}get outputColorSpace(){return this._outputColorSpace}set outputColorSpace(e){this._outputColorSpace=e;const t=this.getContext();t.drawingBufferColorspace=ut._getDrawingBufferColorSpace(e),t.unpackColorSpace=ut._getUnpackColorSpace()}}function Xx(){const r=window.matchMedia("(prefers-reduced-motion: reduce)").matches;if(window.innerWidth<768||r)return;const e=document.getElementById("hero-canvas");if(!e)return;const t=new Wx({canvas:e,alpha:!0,antialias:!1});t.setPixelRatio(Math.min(window.devicePixelRatio,2)),t.setSize(window.innerWidth,window.innerHeight);const n=new jm,i=new Jn(60,window.innerWidth/window.innerHeight,.1,1e3);i.position.z=300;const s=900,a=new hi,o=new Float32Array(s*3),l=new Float32Array(s*3),c=new Float32Array(s),u=[new nt("#F97316"),new nt("#F97316"),new nt("#FB923C"),new nt("#F59E0B"),new nt("#FCD34D"),new nt("#EA580C"),new nt("#6366F1")],h=380;for(let U=0;U<s;U++){const O=Math.random()*Math.PI*2,G=Math.acos(2*Math.random()-1),Y=80+Math.random()*h;o[U*3]=Y*Math.sin(G)*Math.cos(O),o[U*3+1]=Y*Math.sin(G)*Math.sin(O),o[U*3+2]=Y*Math.cos(G)-100;const H=u[Math.floor(Math.random()*u.length)];l[U*3]=H.r,l[U*3+1]=H.g,l[U*3+2]=H.b,c[U]=.4+Math.random()*2.2}a.setAttribute("position",new En(o,3)),a.setAttribute("color",new En(l,3)),a.setAttribute("size",new En(c,1));const d=new ad({size:2.5,vertexColors:!0,transparent:!0,opacity:.75,sizeAttenuation:!0,blending:zo,depthWrite:!1}),f=new n_(a,d);n.add(f);const g=new hi,_=[],m=60,p=200;let T=0;const E=Array.from({length:s},(U,O)=>({x:o[O*3],y:o[O*3+1],z:o[O*3+2]}));for(let U=0;U<s&&T<p;U++)for(let O=U+1;O<s&&T<p;O++){const G=E[U].x-E[O].x,Y=E[U].y-E[O].y,H=E[U].z-E[O].z;Math.sqrt(G*G+Y*Y+H*H)<m&&(_.push(E[U].x,E[U].y,E[U].z),_.push(E[O].x,E[O].y,E[O].z),T++)}if(_.length>0){g.setAttribute("position",new En(new Float32Array(_),3));const U=new sd({vertexColors:!1,color:new nt("#F97316"),transparent:!0,opacity:.08,blending:zo,depthWrite:!1}),O=new t_(g,U);n.add(O)}let x=0,R=0,w=0,b=0;document.addEventListener("mousemove",U=>{x=(U.clientX/window.innerWidth-.5)*2,R=(U.clientY/window.innerHeight-.5)*2}),window.addEventListener("resize",()=>{if(window.innerWidth<768){t.domElement.style.display="none";return}i.aspect=window.innerWidth/window.innerHeight,i.updateProjectionMatrix(),t.setSize(window.innerWidth,window.innerHeight)});let C;const M=new o_;function v(){C=requestAnimationFrame(v);const U=M.getElapsedTime();f.rotation.y=U*.04,f.rotation.x=U*.015,f.position.z=Math.sin(U*.3)*5,w+=(x*25-w)*.04,b+=(-R*20-b)*.04,i.position.x=w,i.position.y=b,i.lookAt(0,0,0),t.render(n,i)}v();const P=document.getElementById("hero");P&&new IntersectionObserver(([O])=>{O.isIntersecting?v():cancelAnimationFrame(C)},{threshold:0}).observe(P)}function Ri(r){if(r===void 0)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return r}function dd(r,e){r.prototype=Object.create(e.prototype),r.prototype.constructor=r,r.__proto__=e}/*!
 * GSAP 3.14.2
 * https://gsap.com
 *
 * @license Copyright 2008-2025, GreenSock. All rights reserved.
 * Subject to the terms at https://gsap.com/standard-license
 * @author: Jack Doyle, jack@greensock.com
*/var Gn={autoSleep:120,force3D:"auto",nullTargetWarn:1,units:{lineHeight:""}},Us={duration:.5,overwrite:!1,delay:0},Eu,en,bt,ti=1e8,xt=1/ti,Wc=Math.PI*2,qx=Wc/4,Yx=0,pd=Math.sqrt,$x=Math.cos,Kx=Math.sin,jt=function(e){return typeof e=="string"},Dt=function(e){return typeof e=="function"},Hi=function(e){return typeof e=="number"},Tu=function(e){return typeof e>"u"},Si=function(e){return typeof e=="object"},An=function(e){return e!==!1},bu=function(){return typeof window<"u"},uo=function(e){return Dt(e)||jt(e)},md=typeof ArrayBuffer=="function"&&ArrayBuffer.isView||function(){},ln=Array.isArray,Zx=/random\([^)]+\)/g,jx=/,\s*/g,jf=/(?:-?\.?\d|\.)+/gi,_d=/[-+=.]*\d+[.e\-+]*\d*[e\-+]*\d*/g,ms=/[-+=.]*\d+[.e-]*\d*[a-z%]*/g,Hl=/[-+=.]*\d+\.?\d*(?:e-|e\+)?\d*/gi,gd=/[+-]=-?[.\d]+/,Jx=/[^,'"\[\]\s]+/gi,Qx=/^[+\-=e\s\d]*\d+[.\d]*([a-z]*|%)\s*$/i,wt,di,Xc,Au,Wn={},Xo={},vd,xd=function(e){return(Xo=Ns(e,Wn))&&Pn},wu=function(e,t){return console.warn("Invalid property",e,"set to",t,"Missing plugin? gsap.registerPlugin()")},ya=function(e,t){return!t&&console.warn(e)},Md=function(e,t){return e&&(Wn[e]=t)&&Xo&&(Xo[e]=t)||Wn},Ea=function(){return 0},eM={suppressEvents:!0,isStart:!0,kill:!1},Po={suppressEvents:!0,kill:!1},tM={suppressEvents:!0},Ru={},rr=[],qc={},Sd,On={},Vl={},Jf=30,Do=[],Cu="",Pu=function(e){var t=e[0],n,i;if(Si(t)||Dt(t)||(e=[e]),!(n=(t._gsap||{}).harness)){for(i=Do.length;i--&&!Do[i].targetTest(t););n=Do[i]}for(i=e.length;i--;)e[i]&&(e[i]._gsap||(e[i]._gsap=new Xd(e[i],n)))||e.splice(i,1);return e},Ur=function(e){return e._gsap||Pu(ni(e))[0]._gsap},yd=function(e,t,n){return(n=e[t])&&Dt(n)?e[t]():Tu(n)&&e.getAttribute&&e.getAttribute(t)||n},wn=function(e,t){return(e=e.split(",")).forEach(t)||e},Ut=function(e){return Math.round(e*1e5)/1e5||0},At=function(e){return Math.round(e*1e7)/1e7||0},Ss=function(e,t){var n=t.charAt(0),i=parseFloat(t.substr(2));return e=parseFloat(e),n==="+"?e+i:n==="-"?e-i:n==="*"?e*i:e/i},nM=function(e,t){for(var n=t.length,i=0;e.indexOf(t[i])<0&&++i<n;);return i<n},qo=function(){var e=rr.length,t=rr.slice(0),n,i;for(qc={},rr.length=0,n=0;n<e;n++)i=t[n],i&&i._lazy&&(i.render(i._lazy[0],i._lazy[1],!0)._lazy=0)},Du=function(e){return!!(e._initted||e._startAt||e.add)},Ed=function(e,t,n,i){rr.length&&!en&&qo(),e.render(t,n,!!(en&&t<0&&Du(e))),rr.length&&!en&&qo()},Td=function(e){var t=parseFloat(e);return(t||t===0)&&(e+"").match(Jx).length<2?t:jt(e)?e.trim():e},bd=function(e){return e},Xn=function(e,t){for(var n in t)n in e||(e[n]=t[n]);return e},iM=function(e){return function(t,n){for(var i in n)i in t||i==="duration"&&e||i==="ease"||(t[i]=n[i])}},Ns=function(e,t){for(var n in t)e[n]=t[n];return e},Qf=function r(e,t){for(var n in t)n!=="__proto__"&&n!=="constructor"&&n!=="prototype"&&(e[n]=Si(t[n])?r(e[n]||(e[n]={}),t[n]):t[n]);return e},Yo=function(e,t){var n={},i;for(i in e)i in t||(n[i]=e[i]);return n},la=function(e){var t=e.parent||wt,n=e.keyframes?iM(ln(e.keyframes)):Xn;if(An(e.inherit))for(;t;)n(e,t.vars.defaults),t=t.parent||t._dp;return e},rM=function(e,t){for(var n=e.length,i=n===t.length;i&&n--&&e[n]===t[n];);return n<0},Ad=function(e,t,n,i,s){var a=e[i],o;if(s)for(o=t[s];a&&a[s]>o;)a=a._prev;return a?(t._next=a._next,a._next=t):(t._next=e[n],e[n]=t),t._next?t._next._prev=t:e[i]=t,t._prev=a,t.parent=t._dp=e,t},sl=function(e,t,n,i){n===void 0&&(n="_first"),i===void 0&&(i="_last");var s=t._prev,a=t._next;s?s._next=a:e[n]===t&&(e[n]=a),a?a._prev=s:e[i]===t&&(e[i]=s),t._next=t._prev=t.parent=null},cr=function(e,t){e.parent&&(!t||e.parent.autoRemoveChildren)&&e.parent.remove&&e.parent.remove(e),e._act=0},Nr=function(e,t){if(e&&(!t||t._end>e._dur||t._start<0))for(var n=e;n;)n._dirty=1,n=n.parent;return e},sM=function(e){for(var t=e.parent;t&&t.parent;)t._dirty=1,t.totalDuration(),t=t.parent;return e},Yc=function(e,t,n,i){return e._startAt&&(en?e._startAt.revert(Po):e.vars.immediateRender&&!e.vars.autoRevert||e._startAt.render(t,!0,i))},aM=function r(e){return!e||e._ts&&r(e.parent)},eh=function(e){return e._repeat?Fs(e._tTime,e=e.duration()+e._rDelay)*e:0},Fs=function(e,t){var n=Math.floor(e=At(e/t));return e&&n===e?n-1:n},$o=function(e,t){return(e-t._start)*t._ts+(t._ts>=0?0:t._dirty?t.totalDuration():t._tDur)},al=function(e){return e._end=At(e._start+(e._tDur/Math.abs(e._ts||e._rts||xt)||0))},ol=function(e,t){var n=e._dp;return n&&n.smoothChildTiming&&e._ts&&(e._start=At(n._time-(e._ts>0?t/e._ts:((e._dirty?e.totalDuration():e._tDur)-t)/-e._ts)),al(e),n._dirty||Nr(n,e)),e},wd=function(e,t){var n;if((t._time||!t._dur&&t._initted||t._start<e._time&&(t._dur||!t.add))&&(n=$o(e.rawTime(),t),(!t._dur||Oa(0,t.totalDuration(),n)-t._tTime>xt)&&t.render(n,!0)),Nr(e,t)._dp&&e._initted&&e._time>=e._dur&&e._ts){if(e._dur<e.duration())for(n=e;n._dp;)n.rawTime()>=0&&n.totalTime(n._tTime),n=n._dp;e._zTime=-xt}},_i=function(e,t,n,i){return t.parent&&cr(t),t._start=At((Hi(n)?n:n||e!==wt?Zn(e,n,t):e._time)+t._delay),t._end=At(t._start+(t.totalDuration()/Math.abs(t.timeScale())||0)),Ad(e,t,"_first","_last",e._sort?"_start":0),$c(t)||(e._recent=t),i||wd(e,t),e._ts<0&&ol(e,e._tTime),e},Rd=function(e,t){return(Wn.ScrollTrigger||wu("scrollTrigger",t))&&Wn.ScrollTrigger.create(t,e)},Cd=function(e,t,n,i,s){if(Iu(e,t,s),!e._initted)return 1;if(!n&&e._pt&&!en&&(e._dur&&e.vars.lazy!==!1||!e._dur&&e.vars.lazy)&&Sd!==zn.frame)return rr.push(e),e._lazy=[s,i],1},oM=function r(e){var t=e.parent;return t&&t._ts&&t._initted&&!t._lock&&(t.rawTime()<0||r(t))},$c=function(e){var t=e.data;return t==="isFromStart"||t==="isStart"},lM=function(e,t,n,i){var s=e.ratio,a=t<0||!t&&(!e._start&&oM(e)&&!(!e._initted&&$c(e))||(e._ts<0||e._dp._ts<0)&&!$c(e))?0:1,o=e._rDelay,l=0,c,u,h;if(o&&e._repeat&&(l=Oa(0,e._tDur,t),u=Fs(l,o),e._yoyo&&u&1&&(a=1-a),u!==Fs(e._tTime,o)&&(s=1-a,e.vars.repeatRefresh&&e._initted&&e.invalidate())),a!==s||en||i||e._zTime===xt||!t&&e._zTime){if(!e._initted&&Cd(e,t,i,n,l))return;for(h=e._zTime,e._zTime=t||(n?xt:0),n||(n=t&&!h),e.ratio=a,e._from&&(a=1-a),e._time=0,e._tTime=l,c=e._pt;c;)c.r(a,c.d),c=c._next;t<0&&Yc(e,t,n,!0),e._onUpdate&&!n&&Hn(e,"onUpdate"),l&&e._repeat&&!n&&e.parent&&Hn(e,"onRepeat"),(t>=e._tDur||t<0)&&e.ratio===a&&(a&&cr(e,1),!n&&!en&&(Hn(e,a?"onComplete":"onReverseComplete",!0),e._prom&&e._prom()))}else e._zTime||(e._zTime=t)},cM=function(e,t,n){var i;if(n>t)for(i=e._first;i&&i._start<=n;){if(i.data==="isPause"&&i._start>t)return i;i=i._next}else for(i=e._last;i&&i._start>=n;){if(i.data==="isPause"&&i._start<t)return i;i=i._prev}},Os=function(e,t,n,i){var s=e._repeat,a=At(t)||0,o=e._tTime/e._tDur;return o&&!i&&(e._time*=a/e._dur),e._dur=a,e._tDur=s?s<0?1e10:At(a*(s+1)+e._rDelay*s):a,o>0&&!i&&ol(e,e._tTime=e._tDur*o),e.parent&&al(e),n||Nr(e.parent,e),e},th=function(e){return e instanceof gn?Nr(e):Os(e,e._dur)},uM={_start:0,endTime:Ea,totalDuration:Ea},Zn=function r(e,t,n){var i=e.labels,s=e._recent||uM,a=e.duration()>=ti?s.endTime(!1):e._dur,o,l,c;return jt(t)&&(isNaN(t)||t in i)?(l=t.charAt(0),c=t.substr(-1)==="%",o=t.indexOf("="),l==="<"||l===">"?(o>=0&&(t=t.replace(/=/,"")),(l==="<"?s._start:s.endTime(s._repeat>=0))+(parseFloat(t.substr(1))||0)*(c?(o<0?s:n).totalDuration()/100:1)):o<0?(t in i||(i[t]=a),i[t]):(l=parseFloat(t.charAt(o-1)+t.substr(o+1)),c&&n&&(l=l/100*(ln(n)?n[0]:n).totalDuration()),o>1?r(e,t.substr(0,o-1),n)+l:a+l)):t==null?a:+t},ca=function(e,t,n){var i=Hi(t[1]),s=(i?2:1)+(e<2?0:1),a=t[s],o,l;if(i&&(a.duration=t[1]),a.parent=n,e){for(o=a,l=n;l&&!("immediateRender"in o);)o=l.vars.defaults||{},l=An(l.vars.inherit)&&l.parent;a.immediateRender=An(o.immediateRender),e<2?a.runBackwards=1:a.startAt=t[s-1]}return new kt(t[0],a,t[s+1])},dr=function(e,t){return e||e===0?t(e):t},Oa=function(e,t,n){return n<e?e:n>t?t:n},an=function(e,t){return!jt(e)||!(t=Qx.exec(e))?"":t[1]},fM=function(e,t,n){return dr(n,function(i){return Oa(e,t,i)})},Kc=[].slice,Pd=function(e,t){return e&&Si(e)&&"length"in e&&(!t&&!e.length||e.length-1 in e&&Si(e[0]))&&!e.nodeType&&e!==di},hM=function(e,t,n){return n===void 0&&(n=[]),e.forEach(function(i){var s;return jt(i)&&!t||Pd(i,1)?(s=n).push.apply(s,ni(i)):n.push(i)})||n},ni=function(e,t,n){return bt&&!t&&bt.selector?bt.selector(e):jt(e)&&!n&&(Xc||!Bs())?Kc.call((t||Au).querySelectorAll(e),0):ln(e)?hM(e,n):Pd(e)?Kc.call(e,0):e?[e]:[]},Zc=function(e){return e=ni(e)[0]||ya("Invalid scope")||{},function(t){var n=e.current||e.nativeElement||e;return ni(t,n.querySelectorAll?n:n===e?ya("Invalid scope")||Au.createElement("div"):e)}},Dd=function(e){return e.sort(function(){return .5-Math.random()})},Ld=function(e){if(Dt(e))return e;var t=Si(e)?e:{each:e},n=Fr(t.ease),i=t.from||0,s=parseFloat(t.base)||0,a={},o=i>0&&i<1,l=isNaN(i)||o,c=t.axis,u=i,h=i;return jt(i)?u=h={center:.5,edges:.5,end:1}[i]||0:!o&&l&&(u=i[0],h=i[1]),function(d,f,g){var _=(g||t).length,m=a[_],p,T,E,x,R,w,b,C,M;if(!m){if(M=t.grid==="auto"?0:(t.grid||[1,ti])[1],!M){for(b=-ti;b<(b=g[M++].getBoundingClientRect().left)&&M<_;);M<_&&M--}for(m=a[_]=[],p=l?Math.min(M,_)*u-.5:i%M,T=M===ti?0:l?_*h/M-.5:i/M|0,b=0,C=ti,w=0;w<_;w++)E=w%M-p,x=T-(w/M|0),m[w]=R=c?Math.abs(c==="y"?x:E):pd(E*E+x*x),R>b&&(b=R),R<C&&(C=R);i==="random"&&Dd(m),m.max=b-C,m.min=C,m.v=_=(parseFloat(t.amount)||parseFloat(t.each)*(M>_?_-1:c?c==="y"?_/M:M:Math.max(M,_/M))||0)*(i==="edges"?-1:1),m.b=_<0?s-_:s,m.u=an(t.amount||t.each)||0,n=n&&_<0?Vd(n):n}return _=(m[d]-m.min)/m.max||0,At(m.b+(n?n(_):_)*m.v)+m.u}},jc=function(e){var t=Math.pow(10,((e+"").split(".")[1]||"").length);return function(n){var i=At(Math.round(parseFloat(n)/e)*e*t);return(i-i%1)/t+(Hi(n)?0:an(n))}},Id=function(e,t){var n=ln(e),i,s;return!n&&Si(e)&&(i=n=e.radius||ti,e.values?(e=ni(e.values),(s=!Hi(e[0]))&&(i*=i)):e=jc(e.increment)),dr(t,n?Dt(e)?function(a){return s=e(a),Math.abs(s-a)<=i?s:a}:function(a){for(var o=parseFloat(s?a.x:a),l=parseFloat(s?a.y:0),c=ti,u=0,h=e.length,d,f;h--;)s?(d=e[h].x-o,f=e[h].y-l,d=d*d+f*f):d=Math.abs(e[h]-o),d<c&&(c=d,u=h);return u=!i||c<=i?e[u]:a,s||u===a||Hi(a)?u:u+an(a)}:jc(e))},Ud=function(e,t,n,i){return dr(ln(e)?!t:n===!0?!!(n=0):!i,function(){return ln(e)?e[~~(Math.random()*e.length)]:(n=n||1e-5)&&(i=n<1?Math.pow(10,(n+"").length-2):1)&&Math.floor(Math.round((e-n/2+Math.random()*(t-e+n*.99))/n)*n*i)/i})},dM=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return function(i){return t.reduce(function(s,a){return a(s)},i)}},pM=function(e,t){return function(n){return e(parseFloat(n))+(t||an(n))}},mM=function(e,t,n){return Fd(e,t,0,1,n)},Nd=function(e,t,n){return dr(n,function(i){return e[~~t(i)]})},_M=function r(e,t,n){var i=t-e;return ln(e)?Nd(e,r(0,e.length),t):dr(n,function(s){return(i+(s-e)%i)%i+e})},gM=function r(e,t,n){var i=t-e,s=i*2;return ln(e)?Nd(e,r(0,e.length-1),t):dr(n,function(a){return a=(s+(a-e)%s)%s||0,e+(a>i?s-a:a)})},Ta=function(e){return e.replace(Zx,function(t){var n=t.indexOf("[")+1,i=t.substring(n||7,n?t.indexOf("]"):t.length-1).split(jx);return Ud(n?i:+i[0],n?0:+i[1],+i[2]||1e-5)})},Fd=function(e,t,n,i,s){var a=t-e,o=i-n;return dr(s,function(l){return n+((l-e)/a*o||0)})},vM=function r(e,t,n,i){var s=isNaN(e+t)?0:function(f){return(1-f)*e+f*t};if(!s){var a=jt(e),o={},l,c,u,h,d;if(n===!0&&(i=1)&&(n=null),a)e={p:e},t={p:t};else if(ln(e)&&!ln(t)){for(u=[],h=e.length,d=h-2,c=1;c<h;c++)u.push(r(e[c-1],e[c]));h--,s=function(g){g*=h;var _=Math.min(d,~~g);return u[_](g-_)},n=t}else i||(e=Ns(ln(e)?[]:{},e));if(!u){for(l in t)Lu.call(o,e,l,"get",t[l]);s=function(g){return Fu(g,o)||(a?e.p:e)}}}return dr(n,s)},nh=function(e,t,n){var i=e.labels,s=ti,a,o,l;for(a in i)o=i[a]-t,o<0==!!n&&o&&s>(o=Math.abs(o))&&(l=a,s=o);return l},Hn=function(e,t,n){var i=e.vars,s=i[t],a=bt,o=e._ctx,l,c,u;if(s)return l=i[t+"Params"],c=i.callbackScope||e,n&&rr.length&&qo(),o&&(bt=o),u=l?s.apply(c,l):s.call(c),bt=a,u},ta=function(e){return cr(e),e.scrollTrigger&&e.scrollTrigger.kill(!!en),e.progress()<1&&Hn(e,"onInterrupt"),e},_s,Od=[],Bd=function(e){if(e)if(e=!e.name&&e.default||e,bu()||e.headless){var t=e.name,n=Dt(e),i=t&&!n&&e.init?function(){this._props=[]}:e,s={init:Ea,render:Fu,add:Lu,kill:UM,modifier:IM,rawVars:0},a={targetTest:0,get:0,getSetter:Nu,aliases:{},register:0};if(Bs(),e!==i){if(On[t])return;Xn(i,Xn(Yo(e,s),a)),Ns(i.prototype,Ns(s,Yo(e,a))),On[i.prop=t]=i,e.targetTest&&(Do.push(i),Ru[t]=1),t=(t==="css"?"CSS":t.charAt(0).toUpperCase()+t.substr(1))+"Plugin"}Md(t,i),e.register&&e.register(Pn,i,Rn)}else Od.push(e)},vt=255,na={aqua:[0,vt,vt],lime:[0,vt,0],silver:[192,192,192],black:[0,0,0],maroon:[128,0,0],teal:[0,128,128],blue:[0,0,vt],navy:[0,0,128],white:[vt,vt,vt],olive:[128,128,0],yellow:[vt,vt,0],orange:[vt,165,0],gray:[128,128,128],purple:[128,0,128],green:[0,128,0],red:[vt,0,0],pink:[vt,192,203],cyan:[0,vt,vt],transparent:[vt,vt,vt,0]},Gl=function(e,t,n){return e+=e<0?1:e>1?-1:0,(e*6<1?t+(n-t)*e*6:e<.5?n:e*3<2?t+(n-t)*(2/3-e)*6:t)*vt+.5|0},zd=function(e,t,n){var i=e?Hi(e)?[e>>16,e>>8&vt,e&vt]:0:na.black,s,a,o,l,c,u,h,d,f,g;if(!i){if(e.substr(-1)===","&&(e=e.substr(0,e.length-1)),na[e])i=na[e];else if(e.charAt(0)==="#"){if(e.length<6&&(s=e.charAt(1),a=e.charAt(2),o=e.charAt(3),e="#"+s+s+a+a+o+o+(e.length===5?e.charAt(4)+e.charAt(4):"")),e.length===9)return i=parseInt(e.substr(1,6),16),[i>>16,i>>8&vt,i&vt,parseInt(e.substr(7),16)/255];e=parseInt(e.substr(1),16),i=[e>>16,e>>8&vt,e&vt]}else if(e.substr(0,3)==="hsl"){if(i=g=e.match(jf),!t)l=+i[0]%360/360,c=+i[1]/100,u=+i[2]/100,a=u<=.5?u*(c+1):u+c-u*c,s=u*2-a,i.length>3&&(i[3]*=1),i[0]=Gl(l+1/3,s,a),i[1]=Gl(l,s,a),i[2]=Gl(l-1/3,s,a);else if(~e.indexOf("="))return i=e.match(_d),n&&i.length<4&&(i[3]=1),i}else i=e.match(jf)||na.transparent;i=i.map(Number)}return t&&!g&&(s=i[0]/vt,a=i[1]/vt,o=i[2]/vt,h=Math.max(s,a,o),d=Math.min(s,a,o),u=(h+d)/2,h===d?l=c=0:(f=h-d,c=u>.5?f/(2-h-d):f/(h+d),l=h===s?(a-o)/f+(a<o?6:0):h===a?(o-s)/f+2:(s-a)/f+4,l*=60),i[0]=~~(l+.5),i[1]=~~(c*100+.5),i[2]=~~(u*100+.5)),n&&i.length<4&&(i[3]=1),i},kd=function(e){var t=[],n=[],i=-1;return e.split(sr).forEach(function(s){var a=s.match(ms)||[];t.push.apply(t,a),n.push(i+=a.length+1)}),t.c=n,t},ih=function(e,t,n){var i="",s=(e+i).match(sr),a=t?"hsla(":"rgba(",o=0,l,c,u,h;if(!s)return e;if(s=s.map(function(d){return(d=zd(d,t,1))&&a+(t?d[0]+","+d[1]+"%,"+d[2]+"%,"+d[3]:d.join(","))+")"}),n&&(u=kd(e),l=n.c,l.join(i)!==u.c.join(i)))for(c=e.replace(sr,"1").split(ms),h=c.length-1;o<h;o++)i+=c[o]+(~l.indexOf(o)?s.shift()||a+"0,0,0,0)":(u.length?u:s.length?s:n).shift());if(!c)for(c=e.split(sr),h=c.length-1;o<h;o++)i+=c[o]+s[o];return i+c[h]},sr=function(){var r="(?:\\b(?:(?:rgb|rgba|hsl|hsla)\\(.+?\\))|\\B#(?:[0-9a-f]{3,4}){1,2}\\b",e;for(e in na)r+="|"+e+"\\b";return new RegExp(r+")","gi")}(),xM=/hsl[a]?\(/,Hd=function(e){var t=e.join(" "),n;if(sr.lastIndex=0,sr.test(t))return n=xM.test(t),e[1]=ih(e[1],n),e[0]=ih(e[0],n,kd(e[1])),!0},ba,zn=function(){var r=Date.now,e=500,t=33,n=r(),i=n,s=1e3/240,a=s,o=[],l,c,u,h,d,f,g=function _(m){var p=r()-i,T=m===!0,E,x,R,w;if((p>e||p<0)&&(n+=p-t),i+=p,R=i-n,E=R-a,(E>0||T)&&(w=++h.frame,d=R-h.time*1e3,h.time=R=R/1e3,a+=E+(E>=s?4:s-E),x=1),T||(l=c(_)),x)for(f=0;f<o.length;f++)o[f](R,d,w,m)};return h={time:0,frame:0,tick:function(){g(!0)},deltaRatio:function(m){return d/(1e3/(m||60))},wake:function(){vd&&(!Xc&&bu()&&(di=Xc=window,Au=di.document||{},Wn.gsap=Pn,(di.gsapVersions||(di.gsapVersions=[])).push(Pn.version),xd(Xo||di.GreenSockGlobals||!di.gsap&&di||{}),Od.forEach(Bd)),u=typeof requestAnimationFrame<"u"&&requestAnimationFrame,l&&h.sleep(),c=u||function(m){return setTimeout(m,a-h.time*1e3+1|0)},ba=1,g(2))},sleep:function(){(u?cancelAnimationFrame:clearTimeout)(l),ba=0,c=Ea},lagSmoothing:function(m,p){e=m||1/0,t=Math.min(p||33,e)},fps:function(m){s=1e3/(m||240),a=h.time*1e3+s},add:function(m,p,T){var E=p?function(x,R,w,b){m(x,R,w,b),h.remove(E)}:m;return h.remove(m),o[T?"unshift":"push"](E),Bs(),E},remove:function(m,p){~(p=o.indexOf(m))&&o.splice(p,1)&&f>=p&&f--},_listeners:o},h}(),Bs=function(){return!ba&&zn.wake()},at={},MM=/^[\d.\-M][\d.\-,\s]/,SM=/["']/g,yM=function(e){for(var t={},n=e.substr(1,e.length-3).split(":"),i=n[0],s=1,a=n.length,o,l,c;s<a;s++)l=n[s],o=s!==a-1?l.lastIndexOf(","):l.length,c=l.substr(0,o),t[i]=isNaN(c)?c.replace(SM,"").trim():+c,i=l.substr(o+1).trim();return t},EM=function(e){var t=e.indexOf("(")+1,n=e.indexOf(")"),i=e.indexOf("(",t);return e.substring(t,~i&&i<n?e.indexOf(")",n+1):n)},TM=function(e){var t=(e+"").split("("),n=at[t[0]];return n&&t.length>1&&n.config?n.config.apply(null,~e.indexOf("{")?[yM(t[1])]:EM(e).split(",").map(Td)):at._CE&&MM.test(e)?at._CE("",e):n},Vd=function(e){return function(t){return 1-e(1-t)}},Gd=function r(e,t){for(var n=e._first,i;n;)n instanceof gn?r(n,t):n.vars.yoyoEase&&(!n._yoyo||!n._repeat)&&n._yoyo!==t&&(n.timeline?r(n.timeline,t):(i=n._ease,n._ease=n._yEase,n._yEase=i,n._yoyo=t)),n=n._next},Fr=function(e,t){return e&&(Dt(e)?e:at[e]||TM(e))||t},qr=function(e,t,n,i){n===void 0&&(n=function(l){return 1-t(1-l)}),i===void 0&&(i=function(l){return l<.5?t(l*2)/2:1-t((1-l)*2)/2});var s={easeIn:t,easeOut:n,easeInOut:i},a;return wn(e,function(o){at[o]=Wn[o]=s,at[a=o.toLowerCase()]=n;for(var l in s)at[a+(l==="easeIn"?".in":l==="easeOut"?".out":".inOut")]=at[o+"."+l]=s[l]}),s},Wd=function(e){return function(t){return t<.5?(1-e(1-t*2))/2:.5+e((t-.5)*2)/2}},Wl=function r(e,t,n){var i=t>=1?t:1,s=(n||(e?.3:.45))/(t<1?t:1),a=s/Wc*(Math.asin(1/i)||0),o=function(u){return u===1?1:i*Math.pow(2,-10*u)*Kx((u-a)*s)+1},l=e==="out"?o:e==="in"?function(c){return 1-o(1-c)}:Wd(o);return s=Wc/s,l.config=function(c,u){return r(e,c,u)},l},Xl=function r(e,t){t===void 0&&(t=1.70158);var n=function(a){return a?--a*a*((t+1)*a+t)+1:0},i=e==="out"?n:e==="in"?function(s){return 1-n(1-s)}:Wd(n);return i.config=function(s){return r(e,s)},i};wn("Linear,Quad,Cubic,Quart,Quint,Strong",function(r,e){var t=e<5?e+1:e;qr(r+",Power"+(t-1),e?function(n){return Math.pow(n,t)}:function(n){return n},function(n){return 1-Math.pow(1-n,t)},function(n){return n<.5?Math.pow(n*2,t)/2:1-Math.pow((1-n)*2,t)/2})});at.Linear.easeNone=at.none=at.Linear.easeIn;qr("Elastic",Wl("in"),Wl("out"),Wl());(function(r,e){var t=1/e,n=2*t,i=2.5*t,s=function(o){return o<t?r*o*o:o<n?r*Math.pow(o-1.5/e,2)+.75:o<i?r*(o-=2.25/e)*o+.9375:r*Math.pow(o-2.625/e,2)+.984375};qr("Bounce",function(a){return 1-s(1-a)},s)})(7.5625,2.75);qr("Expo",function(r){return Math.pow(2,10*(r-1))*r+r*r*r*r*r*r*(1-r)});qr("Circ",function(r){return-(pd(1-r*r)-1)});qr("Sine",function(r){return r===1?1:-$x(r*qx)+1});qr("Back",Xl("in"),Xl("out"),Xl());at.SteppedEase=at.steps=Wn.SteppedEase={config:function(e,t){e===void 0&&(e=1);var n=1/e,i=e+(t?0:1),s=t?1:0,a=1-xt;return function(o){return((i*Oa(0,a,o)|0)+s)*n}}};Us.ease=at["quad.out"];wn("onComplete,onUpdate,onStart,onRepeat,onReverseComplete,onInterrupt",function(r){return Cu+=r+","+r+"Params,"});var Xd=function(e,t){this.id=Yx++,e._gsap=this,this.target=e,this.harness=t,this.get=t?t.get:yd,this.set=t?t.getSetter:Nu},Aa=function(){function r(t){this.vars=t,this._delay=+t.delay||0,(this._repeat=t.repeat===1/0?-2:t.repeat||0)&&(this._rDelay=t.repeatDelay||0,this._yoyo=!!t.yoyo||!!t.yoyoEase),this._ts=1,Os(this,+t.duration,1,1),this.data=t.data,bt&&(this._ctx=bt,bt.data.push(this)),ba||zn.wake()}var e=r.prototype;return e.delay=function(n){return n||n===0?(this.parent&&this.parent.smoothChildTiming&&this.startTime(this._start+n-this._delay),this._delay=n,this):this._delay},e.duration=function(n){return arguments.length?this.totalDuration(this._repeat>0?n+(n+this._rDelay)*this._repeat:n):this.totalDuration()&&this._dur},e.totalDuration=function(n){return arguments.length?(this._dirty=0,Os(this,this._repeat<0?n:(n-this._repeat*this._rDelay)/(this._repeat+1))):this._tDur},e.totalTime=function(n,i){if(Bs(),!arguments.length)return this._tTime;var s=this._dp;if(s&&s.smoothChildTiming&&this._ts){for(ol(this,n),!s._dp||s.parent||wd(s,this);s&&s.parent;)s.parent._time!==s._start+(s._ts>=0?s._tTime/s._ts:(s.totalDuration()-s._tTime)/-s._ts)&&s.totalTime(s._tTime,!0),s=s.parent;!this.parent&&this._dp.autoRemoveChildren&&(this._ts>0&&n<this._tDur||this._ts<0&&n>0||!this._tDur&&!n)&&_i(this._dp,this,this._start-this._delay)}return(this._tTime!==n||!this._dur&&!i||this._initted&&Math.abs(this._zTime)===xt||!this._initted&&this._dur&&n||!n&&!this._initted&&(this.add||this._ptLookup))&&(this._ts||(this._pTime=n),Ed(this,n,i)),this},e.time=function(n,i){return arguments.length?this.totalTime(Math.min(this.totalDuration(),n+eh(this))%(this._dur+this._rDelay)||(n?this._dur:0),i):this._time},e.totalProgress=function(n,i){return arguments.length?this.totalTime(this.totalDuration()*n,i):this.totalDuration()?Math.min(1,this._tTime/this._tDur):this.rawTime()>=0&&this._initted?1:0},e.progress=function(n,i){return arguments.length?this.totalTime(this.duration()*(this._yoyo&&!(this.iteration()&1)?1-n:n)+eh(this),i):this.duration()?Math.min(1,this._time/this._dur):this.rawTime()>0?1:0},e.iteration=function(n,i){var s=this.duration()+this._rDelay;return arguments.length?this.totalTime(this._time+(n-1)*s,i):this._repeat?Fs(this._tTime,s)+1:1},e.timeScale=function(n,i){if(!arguments.length)return this._rts===-xt?0:this._rts;if(this._rts===n)return this;var s=this.parent&&this._ts?$o(this.parent._time,this):this._tTime;return this._rts=+n||0,this._ts=this._ps||n===-xt?0:this._rts,this.totalTime(Oa(-Math.abs(this._delay),this.totalDuration(),s),i!==!1),al(this),sM(this)},e.paused=function(n){return arguments.length?(this._ps!==n&&(this._ps=n,n?(this._pTime=this._tTime||Math.max(-this._delay,this.rawTime()),this._ts=this._act=0):(Bs(),this._ts=this._rts,this.totalTime(this.parent&&!this.parent.smoothChildTiming?this.rawTime():this._tTime||this._pTime,this.progress()===1&&Math.abs(this._zTime)!==xt&&(this._tTime-=xt)))),this):this._ps},e.startTime=function(n){if(arguments.length){this._start=At(n);var i=this.parent||this._dp;return i&&(i._sort||!this.parent)&&_i(i,this,this._start-this._delay),this}return this._start},e.endTime=function(n){return this._start+(An(n)?this.totalDuration():this.duration())/Math.abs(this._ts||1)},e.rawTime=function(n){var i=this.parent||this._dp;return i?n&&(!this._ts||this._repeat&&this._time&&this.totalProgress()<1)?this._tTime%(this._dur+this._rDelay):this._ts?$o(i.rawTime(n),this):this._tTime:this._tTime},e.revert=function(n){n===void 0&&(n=tM);var i=en;return en=n,Du(this)&&(this.timeline&&this.timeline.revert(n),this.totalTime(-.01,n.suppressEvents)),this.data!=="nested"&&n.kill!==!1&&this.kill(),en=i,this},e.globalTime=function(n){for(var i=this,s=arguments.length?n:i.rawTime();i;)s=i._start+s/(Math.abs(i._ts)||1),i=i._dp;return!this.parent&&this._sat?this._sat.globalTime(n):s},e.repeat=function(n){return arguments.length?(this._repeat=n===1/0?-2:n,th(this)):this._repeat===-2?1/0:this._repeat},e.repeatDelay=function(n){if(arguments.length){var i=this._time;return this._rDelay=n,th(this),i?this.time(i):this}return this._rDelay},e.yoyo=function(n){return arguments.length?(this._yoyo=n,this):this._yoyo},e.seek=function(n,i){return this.totalTime(Zn(this,n),An(i))},e.restart=function(n,i){return this.play().totalTime(n?-this._delay:0,An(i)),this._dur||(this._zTime=-xt),this},e.play=function(n,i){return n!=null&&this.seek(n,i),this.reversed(!1).paused(!1)},e.reverse=function(n,i){return n!=null&&this.seek(n||this.totalDuration(),i),this.reversed(!0).paused(!1)},e.pause=function(n,i){return n!=null&&this.seek(n,i),this.paused(!0)},e.resume=function(){return this.paused(!1)},e.reversed=function(n){return arguments.length?(!!n!==this.reversed()&&this.timeScale(-this._rts||(n?-xt:0)),this):this._rts<0},e.invalidate=function(){return this._initted=this._act=0,this._zTime=-xt,this},e.isActive=function(){var n=this.parent||this._dp,i=this._start,s;return!!(!n||this._ts&&this._initted&&n.isActive()&&(s=n.rawTime(!0))>=i&&s<this.endTime(!0)-xt)},e.eventCallback=function(n,i,s){var a=this.vars;return arguments.length>1?(i?(a[n]=i,s&&(a[n+"Params"]=s),n==="onUpdate"&&(this._onUpdate=i)):delete a[n],this):a[n]},e.then=function(n){var i=this,s=i._prom;return new Promise(function(a){var o=Dt(n)?n:bd,l=function(){var u=i.then;i.then=null,s&&s(),Dt(o)&&(o=o(i))&&(o.then||o===i)&&(i.then=u),a(o),i.then=u};i._initted&&i.totalProgress()===1&&i._ts>=0||!i._tTime&&i._ts<0?l():i._prom=l})},e.kill=function(){ta(this)},r}();Xn(Aa.prototype,{_time:0,_start:0,_end:0,_tTime:0,_tDur:0,_dirty:0,_repeat:0,_yoyo:!1,parent:null,_initted:!1,_rDelay:0,_ts:1,_dp:0,ratio:0,_zTime:-xt,_prom:0,_ps:!1,_rts:1});var gn=function(r){dd(e,r);function e(n,i){var s;return n===void 0&&(n={}),s=r.call(this,n)||this,s.labels={},s.smoothChildTiming=!!n.smoothChildTiming,s.autoRemoveChildren=!!n.autoRemoveChildren,s._sort=An(n.sortChildren),wt&&_i(n.parent||wt,Ri(s),i),n.reversed&&s.reverse(),n.paused&&s.paused(!0),n.scrollTrigger&&Rd(Ri(s),n.scrollTrigger),s}var t=e.prototype;return t.to=function(i,s,a){return ca(0,arguments,this),this},t.from=function(i,s,a){return ca(1,arguments,this),this},t.fromTo=function(i,s,a,o){return ca(2,arguments,this),this},t.set=function(i,s,a){return s.duration=0,s.parent=this,la(s).repeatDelay||(s.repeat=0),s.immediateRender=!!s.immediateRender,new kt(i,s,Zn(this,a),1),this},t.call=function(i,s,a){return _i(this,kt.delayedCall(0,i,s),a)},t.staggerTo=function(i,s,a,o,l,c,u){return a.duration=s,a.stagger=a.stagger||o,a.onComplete=c,a.onCompleteParams=u,a.parent=this,new kt(i,a,Zn(this,l)),this},t.staggerFrom=function(i,s,a,o,l,c,u){return a.runBackwards=1,la(a).immediateRender=An(a.immediateRender),this.staggerTo(i,s,a,o,l,c,u)},t.staggerFromTo=function(i,s,a,o,l,c,u,h){return o.startAt=a,la(o).immediateRender=An(o.immediateRender),this.staggerTo(i,s,o,l,c,u,h)},t.render=function(i,s,a){var o=this._time,l=this._dirty?this.totalDuration():this._tDur,c=this._dur,u=i<=0?0:At(i),h=this._zTime<0!=i<0&&(this._initted||!c),d,f,g,_,m,p,T,E,x,R,w,b;if(this!==wt&&u>l&&i>=0&&(u=l),u!==this._tTime||a||h){if(o!==this._time&&c&&(u+=this._time-o,i+=this._time-o),d=u,x=this._start,E=this._ts,p=!E,h&&(c||(o=this._zTime),(i||!s)&&(this._zTime=i)),this._repeat){if(w=this._yoyo,m=c+this._rDelay,this._repeat<-1&&i<0)return this.totalTime(m*100+i,s,a);if(d=At(u%m),u===l?(_=this._repeat,d=c):(R=At(u/m),_=~~R,_&&_===R&&(d=c,_--),d>c&&(d=c)),R=Fs(this._tTime,m),!o&&this._tTime&&R!==_&&this._tTime-R*m-this._dur<=0&&(R=_),w&&_&1&&(d=c-d,b=1),_!==R&&!this._lock){var C=w&&R&1,M=C===(w&&_&1);if(_<R&&(C=!C),o=C?0:u%c?c:u,this._lock=1,this.render(o||(b?0:At(_*m)),s,!c)._lock=0,this._tTime=u,!s&&this.parent&&Hn(this,"onRepeat"),this.vars.repeatRefresh&&!b&&(this.invalidate()._lock=1,R=_),o&&o!==this._time||p!==!this._ts||this.vars.onRepeat&&!this.parent&&!this._act)return this;if(c=this._dur,l=this._tDur,M&&(this._lock=2,o=C?c:-1e-4,this.render(o,!0),this.vars.repeatRefresh&&!b&&this.invalidate()),this._lock=0,!this._ts&&!p)return this;Gd(this,b)}}if(this._hasPause&&!this._forcing&&this._lock<2&&(T=cM(this,At(o),At(d)),T&&(u-=d-(d=T._start))),this._tTime=u,this._time=d,this._act=!E,this._initted||(this._onUpdate=this.vars.onUpdate,this._initted=1,this._zTime=i,o=0),!o&&u&&c&&!s&&!R&&(Hn(this,"onStart"),this._tTime!==u))return this;if(d>=o&&i>=0)for(f=this._first;f;){if(g=f._next,(f._act||d>=f._start)&&f._ts&&T!==f){if(f.parent!==this)return this.render(i,s,a);if(f.render(f._ts>0?(d-f._start)*f._ts:(f._dirty?f.totalDuration():f._tDur)+(d-f._start)*f._ts,s,a),d!==this._time||!this._ts&&!p){T=0,g&&(u+=this._zTime=-xt);break}}f=g}else{f=this._last;for(var v=i<0?i:d;f;){if(g=f._prev,(f._act||v<=f._end)&&f._ts&&T!==f){if(f.parent!==this)return this.render(i,s,a);if(f.render(f._ts>0?(v-f._start)*f._ts:(f._dirty?f.totalDuration():f._tDur)+(v-f._start)*f._ts,s,a||en&&Du(f)),d!==this._time||!this._ts&&!p){T=0,g&&(u+=this._zTime=v?-xt:xt);break}}f=g}}if(T&&!s&&(this.pause(),T.render(d>=o?0:-xt)._zTime=d>=o?1:-1,this._ts))return this._start=x,al(this),this.render(i,s,a);this._onUpdate&&!s&&Hn(this,"onUpdate",!0),(u===l&&this._tTime>=this.totalDuration()||!u&&o)&&(x===this._start||Math.abs(E)!==Math.abs(this._ts))&&(this._lock||((i||!c)&&(u===l&&this._ts>0||!u&&this._ts<0)&&cr(this,1),!s&&!(i<0&&!o)&&(u||o||!l)&&(Hn(this,u===l&&i>=0?"onComplete":"onReverseComplete",!0),this._prom&&!(u<l&&this.timeScale()>0)&&this._prom())))}return this},t.add=function(i,s){var a=this;if(Hi(s)||(s=Zn(this,s,i)),!(i instanceof Aa)){if(ln(i))return i.forEach(function(o){return a.add(o,s)}),this;if(jt(i))return this.addLabel(i,s);if(Dt(i))i=kt.delayedCall(0,i);else return this}return this!==i?_i(this,i,s):this},t.getChildren=function(i,s,a,o){i===void 0&&(i=!0),s===void 0&&(s=!0),a===void 0&&(a=!0),o===void 0&&(o=-ti);for(var l=[],c=this._first;c;)c._start>=o&&(c instanceof kt?s&&l.push(c):(a&&l.push(c),i&&l.push.apply(l,c.getChildren(!0,s,a)))),c=c._next;return l},t.getById=function(i){for(var s=this.getChildren(1,1,1),a=s.length;a--;)if(s[a].vars.id===i)return s[a]},t.remove=function(i){return jt(i)?this.removeLabel(i):Dt(i)?this.killTweensOf(i):(i.parent===this&&sl(this,i),i===this._recent&&(this._recent=this._last),Nr(this))},t.totalTime=function(i,s){return arguments.length?(this._forcing=1,!this._dp&&this._ts&&(this._start=At(zn.time-(this._ts>0?i/this._ts:(this.totalDuration()-i)/-this._ts))),r.prototype.totalTime.call(this,i,s),this._forcing=0,this):this._tTime},t.addLabel=function(i,s){return this.labels[i]=Zn(this,s),this},t.removeLabel=function(i){return delete this.labels[i],this},t.addPause=function(i,s,a){var o=kt.delayedCall(0,s||Ea,a);return o.data="isPause",this._hasPause=1,_i(this,o,Zn(this,i))},t.removePause=function(i){var s=this._first;for(i=Zn(this,i);s;)s._start===i&&s.data==="isPause"&&cr(s),s=s._next},t.killTweensOf=function(i,s,a){for(var o=this.getTweensOf(i,a),l=o.length;l--;)ji!==o[l]&&o[l].kill(i,s);return this},t.getTweensOf=function(i,s){for(var a=[],o=ni(i),l=this._first,c=Hi(s),u;l;)l instanceof kt?nM(l._targets,o)&&(c?(!ji||l._initted&&l._ts)&&l.globalTime(0)<=s&&l.globalTime(l.totalDuration())>s:!s||l.isActive())&&a.push(l):(u=l.getTweensOf(o,s)).length&&a.push.apply(a,u),l=l._next;return a},t.tweenTo=function(i,s){s=s||{};var a=this,o=Zn(a,i),l=s,c=l.startAt,u=l.onStart,h=l.onStartParams,d=l.immediateRender,f,g=kt.to(a,Xn({ease:s.ease||"none",lazy:!1,immediateRender:!1,time:o,overwrite:"auto",duration:s.duration||Math.abs((o-(c&&"time"in c?c.time:a._time))/a.timeScale())||xt,onStart:function(){if(a.pause(),!f){var m=s.duration||Math.abs((o-(c&&"time"in c?c.time:a._time))/a.timeScale());g._dur!==m&&Os(g,m,0,1).render(g._time,!0,!0),f=1}u&&u.apply(g,h||[])}},s));return d?g.render(0):g},t.tweenFromTo=function(i,s,a){return this.tweenTo(s,Xn({startAt:{time:Zn(this,i)}},a))},t.recent=function(){return this._recent},t.nextLabel=function(i){return i===void 0&&(i=this._time),nh(this,Zn(this,i))},t.previousLabel=function(i){return i===void 0&&(i=this._time),nh(this,Zn(this,i),1)},t.currentLabel=function(i){return arguments.length?this.seek(i,!0):this.previousLabel(this._time+xt)},t.shiftChildren=function(i,s,a){a===void 0&&(a=0);var o=this._first,l=this.labels,c;for(i=At(i);o;)o._start>=a&&(o._start+=i,o._end+=i),o=o._next;if(s)for(c in l)l[c]>=a&&(l[c]+=i);return Nr(this)},t.invalidate=function(i){var s=this._first;for(this._lock=0;s;)s.invalidate(i),s=s._next;return r.prototype.invalidate.call(this,i)},t.clear=function(i){i===void 0&&(i=!0);for(var s=this._first,a;s;)a=s._next,this.remove(s),s=a;return this._dp&&(this._time=this._tTime=this._pTime=0),i&&(this.labels={}),Nr(this)},t.totalDuration=function(i){var s=0,a=this,o=a._last,l=ti,c,u,h;if(arguments.length)return a.timeScale((a._repeat<0?a.duration():a.totalDuration())/(a.reversed()?-i:i));if(a._dirty){for(h=a.parent;o;)c=o._prev,o._dirty&&o.totalDuration(),u=o._start,u>l&&a._sort&&o._ts&&!a._lock?(a._lock=1,_i(a,o,u-o._delay,1)._lock=0):l=u,u<0&&o._ts&&(s-=u,(!h&&!a._dp||h&&h.smoothChildTiming)&&(a._start+=At(u/a._ts),a._time-=u,a._tTime-=u),a.shiftChildren(-u,!1,-1/0),l=0),o._end>s&&o._ts&&(s=o._end),o=c;Os(a,a===wt&&a._time>s?a._time:s,1,1),a._dirty=0}return a._tDur},e.updateRoot=function(i){if(wt._ts&&(Ed(wt,$o(i,wt)),Sd=zn.frame),zn.frame>=Jf){Jf+=Gn.autoSleep||120;var s=wt._first;if((!s||!s._ts)&&Gn.autoSleep&&zn._listeners.length<2){for(;s&&!s._ts;)s=s._next;s||zn.sleep()}}},e}(Aa);Xn(gn.prototype,{_lock:0,_hasPause:0,_forcing:0});var bM=function(e,t,n,i,s,a,o){var l=new Rn(this._pt,e,t,0,1,jd,null,s),c=0,u=0,h,d,f,g,_,m,p,T;for(l.b=n,l.e=i,n+="",i+="",(p=~i.indexOf("random("))&&(i=Ta(i)),a&&(T=[n,i],a(T,e,t),n=T[0],i=T[1]),d=n.match(Hl)||[];h=Hl.exec(i);)g=h[0],_=i.substring(c,h.index),f?f=(f+1)%5:_.substr(-5)==="rgba("&&(f=1),g!==d[u++]&&(m=parseFloat(d[u-1])||0,l._pt={_next:l._pt,p:_||u===1?_:",",s:m,c:g.charAt(1)==="="?Ss(m,g)-m:parseFloat(g)-m,m:f&&f<4?Math.round:0},c=Hl.lastIndex);return l.c=c<i.length?i.substring(c,i.length):"",l.fp=o,(gd.test(i)||p)&&(l.e=0),this._pt=l,l},Lu=function(e,t,n,i,s,a,o,l,c,u){Dt(i)&&(i=i(s||0,e,a));var h=e[t],d=n!=="get"?n:Dt(h)?c?e[t.indexOf("set")||!Dt(e["get"+t.substr(3)])?t:"get"+t.substr(3)](c):e[t]():h,f=Dt(h)?c?PM:Kd:Uu,g;if(jt(i)&&(~i.indexOf("random(")&&(i=Ta(i)),i.charAt(1)==="="&&(g=Ss(d,i)+(an(d)||0),(g||g===0)&&(i=g))),!u||d!==i||Jc)return!isNaN(d*i)&&i!==""?(g=new Rn(this._pt,e,t,+d||0,i-(d||0),typeof h=="boolean"?LM:Zd,0,f),c&&(g.fp=c),o&&g.modifier(o,this,e),this._pt=g):(!h&&!(t in e)&&wu(t,i),bM.call(this,e,t,d,i,f,l||Gn.stringFilter,c))},AM=function(e,t,n,i,s){if(Dt(e)&&(e=ua(e,s,t,n,i)),!Si(e)||e.style&&e.nodeType||ln(e)||md(e))return jt(e)?ua(e,s,t,n,i):e;var a={},o;for(o in e)a[o]=ua(e[o],s,t,n,i);return a},qd=function(e,t,n,i,s,a){var o,l,c,u;if(On[e]&&(o=new On[e]).init(s,o.rawVars?t[e]:AM(t[e],i,s,a,n),n,i,a)!==!1&&(n._pt=l=new Rn(n._pt,s,e,0,1,o.render,o,0,o.priority),n!==_s))for(c=n._ptLookup[n._targets.indexOf(s)],u=o._props.length;u--;)c[o._props[u]]=l;return o},ji,Jc,Iu=function r(e,t,n){var i=e.vars,s=i.ease,a=i.startAt,o=i.immediateRender,l=i.lazy,c=i.onUpdate,u=i.runBackwards,h=i.yoyoEase,d=i.keyframes,f=i.autoRevert,g=e._dur,_=e._startAt,m=e._targets,p=e.parent,T=p&&p.data==="nested"?p.vars.targets:m,E=e._overwrite==="auto"&&!Eu,x=e.timeline,R,w,b,C,M,v,P,U,O,G,Y,H,q;if(x&&(!d||!s)&&(s="none"),e._ease=Fr(s,Us.ease),e._yEase=h?Vd(Fr(h===!0?s:h,Us.ease)):0,h&&e._yoyo&&!e._repeat&&(h=e._yEase,e._yEase=e._ease,e._ease=h),e._from=!x&&!!i.runBackwards,!x||d&&!i.stagger){if(U=m[0]?Ur(m[0]).harness:0,H=U&&i[U.prop],R=Yo(i,Ru),_&&(_._zTime<0&&_.progress(1),t<0&&u&&o&&!f?_.render(-1,!0):_.revert(u&&g?Po:eM),_._lazy=0),a){if(cr(e._startAt=kt.set(m,Xn({data:"isStart",overwrite:!1,parent:p,immediateRender:!0,lazy:!_&&An(l),startAt:null,delay:0,onUpdate:c&&function(){return Hn(e,"onUpdate")},stagger:0},a))),e._startAt._dp=0,e._startAt._sat=e,t<0&&(en||!o&&!f)&&e._startAt.revert(Po),o&&g&&t<=0&&n<=0){t&&(e._zTime=t);return}}else if(u&&g&&!_){if(t&&(o=!1),b=Xn({overwrite:!1,data:"isFromStart",lazy:o&&!_&&An(l),immediateRender:o,stagger:0,parent:p},R),H&&(b[U.prop]=H),cr(e._startAt=kt.set(m,b)),e._startAt._dp=0,e._startAt._sat=e,t<0&&(en?e._startAt.revert(Po):e._startAt.render(-1,!0)),e._zTime=t,!o)r(e._startAt,xt,xt);else if(!t)return}for(e._pt=e._ptCache=0,l=g&&An(l)||l&&!g,w=0;w<m.length;w++){if(M=m[w],P=M._gsap||Pu(m)[w]._gsap,e._ptLookup[w]=G={},qc[P.id]&&rr.length&&qo(),Y=T===m?w:T.indexOf(M),U&&(O=new U).init(M,H||R,e,Y,T)!==!1&&(e._pt=C=new Rn(e._pt,M,O.name,0,1,O.render,O,0,O.priority),O._props.forEach(function(k){G[k]=C}),O.priority&&(v=1)),!U||H)for(b in R)On[b]&&(O=qd(b,R,e,Y,M,T))?O.priority&&(v=1):G[b]=C=Lu.call(e,M,b,"get",R[b],Y,T,0,i.stringFilter);e._op&&e._op[w]&&e.kill(M,e._op[w]),E&&e._pt&&(ji=e,wt.killTweensOf(M,G,e.globalTime(t)),q=!e.parent,ji=0),e._pt&&l&&(qc[P.id]=1)}v&&Jd(e),e._onInit&&e._onInit(e)}e._onUpdate=c,e._initted=(!e._op||e._pt)&&!q,d&&t<=0&&x.render(ti,!0,!0)},wM=function(e,t,n,i,s,a,o,l){var c=(e._pt&&e._ptCache||(e._ptCache={}))[t],u,h,d,f;if(!c)for(c=e._ptCache[t]=[],d=e._ptLookup,f=e._targets.length;f--;){if(u=d[f][t],u&&u.d&&u.d._pt)for(u=u.d._pt;u&&u.p!==t&&u.fp!==t;)u=u._next;if(!u)return Jc=1,e.vars[t]="+=0",Iu(e,o),Jc=0,l?ya(t+" not eligible for reset"):1;c.push(u)}for(f=c.length;f--;)h=c[f],u=h._pt||h,u.s=(i||i===0)&&!s?i:u.s+(i||0)+a*u.c,u.c=n-u.s,h.e&&(h.e=Ut(n)+an(h.e)),h.b&&(h.b=u.s+an(h.b))},RM=function(e,t){var n=e[0]?Ur(e[0]).harness:0,i=n&&n.aliases,s,a,o,l;if(!i)return t;s=Ns({},t);for(a in i)if(a in s)for(l=i[a].split(","),o=l.length;o--;)s[l[o]]=s[a];return s},CM=function(e,t,n,i){var s=t.ease||i||"power1.inOut",a,o;if(ln(t))o=n[e]||(n[e]=[]),t.forEach(function(l,c){return o.push({t:c/(t.length-1)*100,v:l,e:s})});else for(a in t)o=n[a]||(n[a]=[]),a==="ease"||o.push({t:parseFloat(e),v:t[a],e:s})},ua=function(e,t,n,i,s){return Dt(e)?e.call(t,n,i,s):jt(e)&&~e.indexOf("random(")?Ta(e):e},Yd=Cu+"repeat,repeatDelay,yoyo,repeatRefresh,yoyoEase,autoRevert",$d={};wn(Yd+",id,stagger,delay,duration,paused,scrollTrigger",function(r){return $d[r]=1});var kt=function(r){dd(e,r);function e(n,i,s,a){var o;typeof i=="number"&&(s.duration=i,i=s,s=null),o=r.call(this,a?i:la(i))||this;var l=o.vars,c=l.duration,u=l.delay,h=l.immediateRender,d=l.stagger,f=l.overwrite,g=l.keyframes,_=l.defaults,m=l.scrollTrigger,p=l.yoyoEase,T=i.parent||wt,E=(ln(n)||md(n)?Hi(n[0]):"length"in i)?[n]:ni(n),x,R,w,b,C,M,v,P;if(o._targets=E.length?Pu(E):ya("GSAP target "+n+" not found. https://gsap.com",!Gn.nullTargetWarn)||[],o._ptLookup=[],o._overwrite=f,g||d||uo(c)||uo(u)){if(i=o.vars,x=o.timeline=new gn({data:"nested",defaults:_||{},targets:T&&T.data==="nested"?T.vars.targets:E}),x.kill(),x.parent=x._dp=Ri(o),x._start=0,d||uo(c)||uo(u)){if(b=E.length,v=d&&Ld(d),Si(d))for(C in d)~Yd.indexOf(C)&&(P||(P={}),P[C]=d[C]);for(R=0;R<b;R++)w=Yo(i,$d),w.stagger=0,p&&(w.yoyoEase=p),P&&Ns(w,P),M=E[R],w.duration=+ua(c,Ri(o),R,M,E),w.delay=(+ua(u,Ri(o),R,M,E)||0)-o._delay,!d&&b===1&&w.delay&&(o._delay=u=w.delay,o._start+=u,w.delay=0),x.to(M,w,v?v(R,M,E):0),x._ease=at.none;x.duration()?c=u=0:o.timeline=0}else if(g){la(Xn(x.vars.defaults,{ease:"none"})),x._ease=Fr(g.ease||i.ease||"none");var U=0,O,G,Y;if(ln(g))g.forEach(function(H){return x.to(E,H,">")}),x.duration();else{w={};for(C in g)C==="ease"||C==="easeEach"||CM(C,g[C],w,g.easeEach);for(C in w)for(O=w[C].sort(function(H,q){return H.t-q.t}),U=0,R=0;R<O.length;R++)G=O[R],Y={ease:G.e,duration:(G.t-(R?O[R-1].t:0))/100*c},Y[C]=G.v,x.to(E,Y,U),U+=Y.duration;x.duration()<c&&x.to({},{duration:c-x.duration()})}}c||o.duration(c=x.duration())}else o.timeline=0;return f===!0&&!Eu&&(ji=Ri(o),wt.killTweensOf(E),ji=0),_i(T,Ri(o),s),i.reversed&&o.reverse(),i.paused&&o.paused(!0),(h||!c&&!g&&o._start===At(T._time)&&An(h)&&aM(Ri(o))&&T.data!=="nested")&&(o._tTime=-xt,o.render(Math.max(0,-u)||0)),m&&Rd(Ri(o),m),o}var t=e.prototype;return t.render=function(i,s,a){var o=this._time,l=this._tDur,c=this._dur,u=i<0,h=i>l-xt&&!u?l:i<xt?0:i,d,f,g,_,m,p,T,E,x;if(!c)lM(this,i,s,a);else if(h!==this._tTime||!i||a||!this._initted&&this._tTime||this._startAt&&this._zTime<0!==u||this._lazy){if(d=h,E=this.timeline,this._repeat){if(_=c+this._rDelay,this._repeat<-1&&u)return this.totalTime(_*100+i,s,a);if(d=At(h%_),h===l?(g=this._repeat,d=c):(m=At(h/_),g=~~m,g&&g===m?(d=c,g--):d>c&&(d=c)),p=this._yoyo&&g&1,p&&(x=this._yEase,d=c-d),m=Fs(this._tTime,_),d===o&&!a&&this._initted&&g===m)return this._tTime=h,this;g!==m&&(E&&this._yEase&&Gd(E,p),this.vars.repeatRefresh&&!p&&!this._lock&&d!==_&&this._initted&&(this._lock=a=1,this.render(At(_*g),!0).invalidate()._lock=0))}if(!this._initted){if(Cd(this,u?i:d,a,s,h))return this._tTime=0,this;if(o!==this._time&&!(a&&this.vars.repeatRefresh&&g!==m))return this;if(c!==this._dur)return this.render(i,s,a)}if(this._tTime=h,this._time=d,!this._act&&this._ts&&(this._act=1,this._lazy=0),this.ratio=T=(x||this._ease)(d/c),this._from&&(this.ratio=T=1-T),!o&&h&&!s&&!m&&(Hn(this,"onStart"),this._tTime!==h))return this;for(f=this._pt;f;)f.r(T,f.d),f=f._next;E&&E.render(i<0?i:E._dur*E._ease(d/this._dur),s,a)||this._startAt&&(this._zTime=i),this._onUpdate&&!s&&(u&&Yc(this,i,s,a),Hn(this,"onUpdate")),this._repeat&&g!==m&&this.vars.onRepeat&&!s&&this.parent&&Hn(this,"onRepeat"),(h===this._tDur||!h)&&this._tTime===h&&(u&&!this._onUpdate&&Yc(this,i,!0,!0),(i||!c)&&(h===this._tDur&&this._ts>0||!h&&this._ts<0)&&cr(this,1),!s&&!(u&&!o)&&(h||o||p)&&(Hn(this,h===l?"onComplete":"onReverseComplete",!0),this._prom&&!(h<l&&this.timeScale()>0)&&this._prom()))}return this},t.targets=function(){return this._targets},t.invalidate=function(i){return(!i||!this.vars.runBackwards)&&(this._startAt=0),this._pt=this._op=this._onUpdate=this._lazy=this.ratio=0,this._ptLookup=[],this.timeline&&this.timeline.invalidate(i),r.prototype.invalidate.call(this,i)},t.resetTo=function(i,s,a,o,l){ba||zn.wake(),this._ts||this.play();var c=Math.min(this._dur,(this._dp._time-this._start)*this._ts),u;return this._initted||Iu(this,c),u=this._ease(c/this._dur),wM(this,i,s,a,o,u,c,l)?this.resetTo(i,s,a,o,1):(ol(this,0),this.parent||Ad(this._dp,this,"_first","_last",this._dp._sort?"_start":0),this.render(0))},t.kill=function(i,s){if(s===void 0&&(s="all"),!i&&(!s||s==="all"))return this._lazy=this._pt=0,this.parent?ta(this):this.scrollTrigger&&this.scrollTrigger.kill(!!en),this;if(this.timeline){var a=this.timeline.totalDuration();return this.timeline.killTweensOf(i,s,ji&&ji.vars.overwrite!==!0)._first||ta(this),this.parent&&a!==this.timeline.totalDuration()&&Os(this,this._dur*this.timeline._tDur/a,0,1),this}var o=this._targets,l=i?ni(i):o,c=this._ptLookup,u=this._pt,h,d,f,g,_,m,p;if((!s||s==="all")&&rM(o,l))return s==="all"&&(this._pt=0),ta(this);for(h=this._op=this._op||[],s!=="all"&&(jt(s)&&(_={},wn(s,function(T){return _[T]=1}),s=_),s=RM(o,s)),p=o.length;p--;)if(~l.indexOf(o[p])){d=c[p],s==="all"?(h[p]=s,g=d,f={}):(f=h[p]=h[p]||{},g=s);for(_ in g)m=d&&d[_],m&&((!("kill"in m.d)||m.d.kill(_)===!0)&&sl(this,m,"_pt"),delete d[_]),f!=="all"&&(f[_]=1)}return this._initted&&!this._pt&&u&&ta(this),this},e.to=function(i,s){return new e(i,s,arguments[2])},e.from=function(i,s){return ca(1,arguments)},e.delayedCall=function(i,s,a,o){return new e(s,0,{immediateRender:!1,lazy:!1,overwrite:!1,delay:i,onComplete:s,onReverseComplete:s,onCompleteParams:a,onReverseCompleteParams:a,callbackScope:o})},e.fromTo=function(i,s,a){return ca(2,arguments)},e.set=function(i,s){return s.duration=0,s.repeatDelay||(s.repeat=0),new e(i,s)},e.killTweensOf=function(i,s,a){return wt.killTweensOf(i,s,a)},e}(Aa);Xn(kt.prototype,{_targets:[],_lazy:0,_startAt:0,_op:0,_onInit:0});wn("staggerTo,staggerFrom,staggerFromTo",function(r){kt[r]=function(){var e=new gn,t=Kc.call(arguments,0);return t.splice(r==="staggerFromTo"?5:4,0,0),e[r].apply(e,t)}});var Uu=function(e,t,n){return e[t]=n},Kd=function(e,t,n){return e[t](n)},PM=function(e,t,n,i){return e[t](i.fp,n)},DM=function(e,t,n){return e.setAttribute(t,n)},Nu=function(e,t){return Dt(e[t])?Kd:Tu(e[t])&&e.setAttribute?DM:Uu},Zd=function(e,t){return t.set(t.t,t.p,Math.round((t.s+t.c*e)*1e6)/1e6,t)},LM=function(e,t){return t.set(t.t,t.p,!!(t.s+t.c*e),t)},jd=function(e,t){var n=t._pt,i="";if(!e&&t.b)i=t.b;else if(e===1&&t.e)i=t.e;else{for(;n;)i=n.p+(n.m?n.m(n.s+n.c*e):Math.round((n.s+n.c*e)*1e4)/1e4)+i,n=n._next;i+=t.c}t.set(t.t,t.p,i,t)},Fu=function(e,t){for(var n=t._pt;n;)n.r(e,n.d),n=n._next},IM=function(e,t,n,i){for(var s=this._pt,a;s;)a=s._next,s.p===i&&s.modifier(e,t,n),s=a},UM=function(e){for(var t=this._pt,n,i;t;)i=t._next,t.p===e&&!t.op||t.op===e?sl(this,t,"_pt"):t.dep||(n=1),t=i;return!n},NM=function(e,t,n,i){i.mSet(e,t,i.m.call(i.tween,n,i.mt),i)},Jd=function(e){for(var t=e._pt,n,i,s,a;t;){for(n=t._next,i=s;i&&i.pr>t.pr;)i=i._next;(t._prev=i?i._prev:a)?t._prev._next=t:s=t,(t._next=i)?i._prev=t:a=t,t=n}e._pt=s},Rn=function(){function r(t,n,i,s,a,o,l,c,u){this.t=n,this.s=s,this.c=a,this.p=i,this.r=o||Zd,this.d=l||this,this.set=c||Uu,this.pr=u||0,this._next=t,t&&(t._prev=this)}var e=r.prototype;return e.modifier=function(n,i,s){this.mSet=this.mSet||this.set,this.set=NM,this.m=n,this.mt=s,this.tween=i},r}();wn(Cu+"parent,duration,ease,delay,overwrite,runBackwards,startAt,yoyo,immediateRender,repeat,repeatDelay,data,paused,reversed,lazy,callbackScope,stringFilter,id,yoyoEase,stagger,inherit,repeatRefresh,keyframes,autoRevert,scrollTrigger",function(r){return Ru[r]=1});Wn.TweenMax=Wn.TweenLite=kt;Wn.TimelineLite=Wn.TimelineMax=gn;wt=new gn({sortChildren:!1,defaults:Us,autoRemoveChildren:!0,id:"root",smoothChildTiming:!0});Gn.stringFilter=Hd;var Or=[],Lo={},FM=[],rh=0,OM=0,ql=function(e){return(Lo[e]||FM).map(function(t){return t()})},Qc=function(){var e=Date.now(),t=[];e-rh>2&&(ql("matchMediaInit"),Or.forEach(function(n){var i=n.queries,s=n.conditions,a,o,l,c;for(o in i)a=di.matchMedia(i[o]).matches,a&&(l=1),a!==s[o]&&(s[o]=a,c=1);c&&(n.revert(),l&&t.push(n))}),ql("matchMediaRevert"),t.forEach(function(n){return n.onMatch(n,function(i){return n.add(null,i)})}),rh=e,ql("matchMedia"))},Qd=function(){function r(t,n){this.selector=n&&Zc(n),this.data=[],this._r=[],this.isReverted=!1,this.id=OM++,t&&this.add(t)}var e=r.prototype;return e.add=function(n,i,s){Dt(n)&&(s=i,i=n,n=Dt);var a=this,o=function(){var c=bt,u=a.selector,h;return c&&c!==a&&c.data.push(a),s&&(a.selector=Zc(s)),bt=a,h=i.apply(a,arguments),Dt(h)&&a._r.push(h),bt=c,a.selector=u,a.isReverted=!1,h};return a.last=o,n===Dt?o(a,function(l){return a.add(null,l)}):n?a[n]=o:o},e.ignore=function(n){var i=bt;bt=null,n(this),bt=i},e.getTweens=function(){var n=[];return this.data.forEach(function(i){return i instanceof r?n.push.apply(n,i.getTweens()):i instanceof kt&&!(i.parent&&i.parent.data==="nested")&&n.push(i)}),n},e.clear=function(){this._r.length=this.data.length=0},e.kill=function(n,i){var s=this;if(n?function(){for(var o=s.getTweens(),l=s.data.length,c;l--;)c=s.data[l],c.data==="isFlip"&&(c.revert(),c.getChildren(!0,!0,!1).forEach(function(u){return o.splice(o.indexOf(u),1)}));for(o.map(function(u){return{g:u._dur||u._delay||u._sat&&!u._sat.vars.immediateRender?u.globalTime(0):-1/0,t:u}}).sort(function(u,h){return h.g-u.g||-1/0}).forEach(function(u){return u.t.revert(n)}),l=s.data.length;l--;)c=s.data[l],c instanceof gn?c.data!=="nested"&&(c.scrollTrigger&&c.scrollTrigger.revert(),c.kill()):!(c instanceof kt)&&c.revert&&c.revert(n);s._r.forEach(function(u){return u(n,s)}),s.isReverted=!0}():this.data.forEach(function(o){return o.kill&&o.kill()}),this.clear(),i)for(var a=Or.length;a--;)Or[a].id===this.id&&Or.splice(a,1)},e.revert=function(n){this.kill(n||{})},r}(),BM=function(){function r(t){this.contexts=[],this.scope=t,bt&&bt.data.push(this)}var e=r.prototype;return e.add=function(n,i,s){Si(n)||(n={matches:n});var a=new Qd(0,s||this.scope),o=a.conditions={},l,c,u;bt&&!a.selector&&(a.selector=bt.selector),this.contexts.push(a),i=a.add("onMatch",i),a.queries=n;for(c in n)c==="all"?u=1:(l=di.matchMedia(n[c]),l&&(Or.indexOf(a)<0&&Or.push(a),(o[c]=l.matches)&&(u=1),l.addListener?l.addListener(Qc):l.addEventListener("change",Qc)));return u&&i(a,function(h){return a.add(null,h)}),this},e.revert=function(n){this.kill(n||{})},e.kill=function(n){this.contexts.forEach(function(i){return i.kill(n,!0)})},r}(),Ko={registerPlugin:function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];t.forEach(function(i){return Bd(i)})},timeline:function(e){return new gn(e)},getTweensOf:function(e,t){return wt.getTweensOf(e,t)},getProperty:function(e,t,n,i){jt(e)&&(e=ni(e)[0]);var s=Ur(e||{}).get,a=n?bd:Td;return n==="native"&&(n=""),e&&(t?a((On[t]&&On[t].get||s)(e,t,n,i)):function(o,l,c){return a((On[o]&&On[o].get||s)(e,o,l,c))})},quickSetter:function(e,t,n){if(e=ni(e),e.length>1){var i=e.map(function(u){return Pn.quickSetter(u,t,n)}),s=i.length;return function(u){for(var h=s;h--;)i[h](u)}}e=e[0]||{};var a=On[t],o=Ur(e),l=o.harness&&(o.harness.aliases||{})[t]||t,c=a?function(u){var h=new a;_s._pt=0,h.init(e,n?u+n:u,_s,0,[e]),h.render(1,h),_s._pt&&Fu(1,_s)}:o.set(e,l);return a?c:function(u){return c(e,l,n?u+n:u,o,1)}},quickTo:function(e,t,n){var i,s=Pn.to(e,Xn((i={},i[t]="+=0.1",i.paused=!0,i.stagger=0,i),n||{})),a=function(l,c,u){return s.resetTo(t,l,c,u)};return a.tween=s,a},isTweening:function(e){return wt.getTweensOf(e,!0).length>0},defaults:function(e){return e&&e.ease&&(e.ease=Fr(e.ease,Us.ease)),Qf(Us,e||{})},config:function(e){return Qf(Gn,e||{})},registerEffect:function(e){var t=e.name,n=e.effect,i=e.plugins,s=e.defaults,a=e.extendTimeline;(i||"").split(",").forEach(function(o){return o&&!On[o]&&!Wn[o]&&ya(t+" effect requires "+o+" plugin.")}),Vl[t]=function(o,l,c){return n(ni(o),Xn(l||{},s),c)},a&&(gn.prototype[t]=function(o,l,c){return this.add(Vl[t](o,Si(l)?l:(c=l)&&{},this),c)})},registerEase:function(e,t){at[e]=Fr(t)},parseEase:function(e,t){return arguments.length?Fr(e,t):at},getById:function(e){return wt.getById(e)},exportRoot:function(e,t){e===void 0&&(e={});var n=new gn(e),i,s;for(n.smoothChildTiming=An(e.smoothChildTiming),wt.remove(n),n._dp=0,n._time=n._tTime=wt._time,i=wt._first;i;)s=i._next,(t||!(!i._dur&&i instanceof kt&&i.vars.onComplete===i._targets[0]))&&_i(n,i,i._start-i._delay),i=s;return _i(wt,n,0),n},context:function(e,t){return e?new Qd(e,t):bt},matchMedia:function(e){return new BM(e)},matchMediaRefresh:function(){return Or.forEach(function(e){var t=e.conditions,n,i;for(i in t)t[i]&&(t[i]=!1,n=1);n&&e.revert()})||Qc()},addEventListener:function(e,t){var n=Lo[e]||(Lo[e]=[]);~n.indexOf(t)||n.push(t)},removeEventListener:function(e,t){var n=Lo[e],i=n&&n.indexOf(t);i>=0&&n.splice(i,1)},utils:{wrap:_M,wrapYoyo:gM,distribute:Ld,random:Ud,snap:Id,normalize:mM,getUnit:an,clamp:fM,splitColor:zd,toArray:ni,selector:Zc,mapRange:Fd,pipe:dM,unitize:pM,interpolate:vM,shuffle:Dd},install:xd,effects:Vl,ticker:zn,updateRoot:gn.updateRoot,plugins:On,globalTimeline:wt,core:{PropTween:Rn,globals:Md,Tween:kt,Timeline:gn,Animation:Aa,getCache:Ur,_removeLinkedListItem:sl,reverting:function(){return en},context:function(e){return e&&bt&&(bt.data.push(e),e._ctx=bt),bt},suppressOverwrites:function(e){return Eu=e}}};wn("to,from,fromTo,delayedCall,set,killTweensOf",function(r){return Ko[r]=kt[r]});zn.add(gn.updateRoot);_s=Ko.to({},{duration:0});var zM=function(e,t){for(var n=e._pt;n&&n.p!==t&&n.op!==t&&n.fp!==t;)n=n._next;return n},kM=function(e,t){var n=e._targets,i,s,a;for(i in t)for(s=n.length;s--;)a=e._ptLookup[s][i],a&&(a=a.d)&&(a._pt&&(a=zM(a,i)),a&&a.modifier&&a.modifier(t[i],e,n[s],i))},Yl=function(e,t){return{name:e,headless:1,rawVars:1,init:function(i,s,a){a._onInit=function(o){var l,c;if(jt(s)&&(l={},wn(s,function(u){return l[u]=1}),s=l),t){l={};for(c in s)l[c]=t(s[c]);s=l}kM(o,s)}}}},Pn=Ko.registerPlugin({name:"attr",init:function(e,t,n,i,s){var a,o,l;this.tween=n;for(a in t)l=e.getAttribute(a)||"",o=this.add(e,"setAttribute",(l||0)+"",t[a],i,s,0,0,a),o.op=a,o.b=l,this._props.push(a)},render:function(e,t){for(var n=t._pt;n;)en?n.set(n.t,n.p,n.b,n):n.r(e,n.d),n=n._next}},{name:"endArray",headless:1,init:function(e,t){for(var n=t.length;n--;)this.add(e,n,e[n]||0,t[n],0,0,0,0,0,1)}},Yl("roundProps",jc),Yl("modifiers"),Yl("snap",Id))||Ko;kt.version=gn.version=Pn.version="3.14.2";vd=1;bu()&&Bs();at.Power0;at.Power1;at.Power2;at.Power3;at.Power4;at.Linear;at.Quad;at.Cubic;at.Quart;at.Quint;at.Strong;at.Elastic;at.Back;at.SteppedEase;at.Bounce;at.Sine;at.Expo;at.Circ;/*!
 * CSSPlugin 3.14.2
 * https://gsap.com
 *
 * Copyright 2008-2025, GreenSock. All rights reserved.
 * Subject to the terms at https://gsap.com/standard-license
 * @author: Jack Doyle, jack@greensock.com
*/var sh,Ji,ys,Ou,Lr,ah,Bu,HM=function(){return typeof window<"u"},Vi={},br=180/Math.PI,Es=Math.PI/180,ls=Math.atan2,oh=1e8,zu=/([A-Z])/g,VM=/(left|right|width|margin|padding|x)/i,GM=/[\s,\(]\S/,vi={autoAlpha:"opacity,visibility",scale:"scaleX,scaleY",alpha:"opacity"},eu=function(e,t){return t.set(t.t,t.p,Math.round((t.s+t.c*e)*1e4)/1e4+t.u,t)},WM=function(e,t){return t.set(t.t,t.p,e===1?t.e:Math.round((t.s+t.c*e)*1e4)/1e4+t.u,t)},XM=function(e,t){return t.set(t.t,t.p,e?Math.round((t.s+t.c*e)*1e4)/1e4+t.u:t.b,t)},qM=function(e,t){return t.set(t.t,t.p,e===1?t.e:e?Math.round((t.s+t.c*e)*1e4)/1e4+t.u:t.b,t)},YM=function(e,t){var n=t.s+t.c*e;t.set(t.t,t.p,~~(n+(n<0?-.5:.5))+t.u,t)},ep=function(e,t){return t.set(t.t,t.p,e?t.e:t.b,t)},tp=function(e,t){return t.set(t.t,t.p,e!==1?t.b:t.e,t)},$M=function(e,t,n){return e.style[t]=n},KM=function(e,t,n){return e.style.setProperty(t,n)},ZM=function(e,t,n){return e._gsap[t]=n},jM=function(e,t,n){return e._gsap.scaleX=e._gsap.scaleY=n},JM=function(e,t,n,i,s){var a=e._gsap;a.scaleX=a.scaleY=n,a.renderTransform(s,a)},QM=function(e,t,n,i,s){var a=e._gsap;a[t]=n,a.renderTransform(s,a)},Rt="transform",Cn=Rt+"Origin",eS=function r(e,t){var n=this,i=this.target,s=i.style,a=i._gsap;if(e in Vi&&s){if(this.tfm=this.tfm||{},e!=="transform")e=vi[e]||e,~e.indexOf(",")?e.split(",").forEach(function(o){return n.tfm[o]=Ci(i,o)}):this.tfm[e]=a.x?a[e]:Ci(i,e),e===Cn&&(this.tfm.zOrigin=a.zOrigin);else return vi.transform.split(",").forEach(function(o){return r.call(n,o,t)});if(this.props.indexOf(Rt)>=0)return;a.svg&&(this.svgo=i.getAttribute("data-svg-origin"),this.props.push(Cn,t,"")),e=Rt}(s||t)&&this.props.push(e,t,s[e])},np=function(e){e.translate&&(e.removeProperty("translate"),e.removeProperty("scale"),e.removeProperty("rotate"))},tS=function(){var e=this.props,t=this.target,n=t.style,i=t._gsap,s,a;for(s=0;s<e.length;s+=3)e[s+1]?e[s+1]===2?t[e[s]](e[s+2]):t[e[s]]=e[s+2]:e[s+2]?n[e[s]]=e[s+2]:n.removeProperty(e[s].substr(0,2)==="--"?e[s]:e[s].replace(zu,"-$1").toLowerCase());if(this.tfm){for(a in this.tfm)i[a]=this.tfm[a];i.svg&&(i.renderTransform(),t.setAttribute("data-svg-origin",this.svgo||"")),s=Bu(),(!s||!s.isStart)&&!n[Rt]&&(np(n),i.zOrigin&&n[Cn]&&(n[Cn]+=" "+i.zOrigin+"px",i.zOrigin=0,i.renderTransform()),i.uncache=1)}},ip=function(e,t){var n={target:e,props:[],revert:tS,save:eS};return e._gsap||Pn.core.getCache(e),t&&e.style&&e.nodeType&&t.split(",").forEach(function(i){return n.save(i)}),n},rp,tu=function(e,t){var n=Ji.createElementNS?Ji.createElementNS((t||"http://www.w3.org/1999/xhtml").replace(/^https/,"http"),e):Ji.createElement(e);return n&&n.style?n:Ji.createElement(e)},Vn=function r(e,t,n){var i=getComputedStyle(e);return i[t]||i.getPropertyValue(t.replace(zu,"-$1").toLowerCase())||i.getPropertyValue(t)||!n&&r(e,zs(t)||t,1)||""},lh="O,Moz,ms,Ms,Webkit".split(","),zs=function(e,t,n){var i=t||Lr,s=i.style,a=5;if(e in s&&!n)return e;for(e=e.charAt(0).toUpperCase()+e.substr(1);a--&&!(lh[a]+e in s););return a<0?null:(a===3?"ms":a>=0?lh[a]:"")+e},nu=function(){HM()&&window.document&&(sh=window,Ji=sh.document,ys=Ji.documentElement,Lr=tu("div")||{style:{}},tu("div"),Rt=zs(Rt),Cn=Rt+"Origin",Lr.style.cssText="border-width:0;line-height:0;position:absolute;padding:0",rp=!!zs("perspective"),Bu=Pn.core.reverting,Ou=1)},ch=function(e){var t=e.ownerSVGElement,n=tu("svg",t&&t.getAttribute("xmlns")||"http://www.w3.org/2000/svg"),i=e.cloneNode(!0),s;i.style.display="block",n.appendChild(i),ys.appendChild(n);try{s=i.getBBox()}catch{}return n.removeChild(i),ys.removeChild(n),s},uh=function(e,t){for(var n=t.length;n--;)if(e.hasAttribute(t[n]))return e.getAttribute(t[n])},sp=function(e){var t,n;try{t=e.getBBox()}catch{t=ch(e),n=1}return t&&(t.width||t.height)||n||(t=ch(e)),t&&!t.width&&!t.x&&!t.y?{x:+uh(e,["x","cx","x1"])||0,y:+uh(e,["y","cy","y1"])||0,width:0,height:0}:t},ap=function(e){return!!(e.getCTM&&(!e.parentNode||e.ownerSVGElement)&&sp(e))},ur=function(e,t){if(t){var n=e.style,i;t in Vi&&t!==Cn&&(t=Rt),n.removeProperty?(i=t.substr(0,2),(i==="ms"||t.substr(0,6)==="webkit")&&(t="-"+t),n.removeProperty(i==="--"?t:t.replace(zu,"-$1").toLowerCase())):n.removeAttribute(t)}},Qi=function(e,t,n,i,s,a){var o=new Rn(e._pt,t,n,0,1,a?tp:ep);return e._pt=o,o.b=i,o.e=s,e._props.push(n),o},fh={deg:1,rad:1,turn:1},nS={grid:1,flex:1},fr=function r(e,t,n,i){var s=parseFloat(n)||0,a=(n+"").trim().substr((s+"").length)||"px",o=Lr.style,l=VM.test(t),c=e.tagName.toLowerCase()==="svg",u=(c?"client":"offset")+(l?"Width":"Height"),h=100,d=i==="px",f=i==="%",g,_,m,p;if(i===a||!s||fh[i]||fh[a])return s;if(a!=="px"&&!d&&(s=r(e,t,n,"px")),p=e.getCTM&&ap(e),(f||a==="%")&&(Vi[t]||~t.indexOf("adius")))return g=p?e.getBBox()[l?"width":"height"]:e[u],Ut(f?s/g*h:s/100*g);if(o[l?"width":"height"]=h+(d?a:i),_=i!=="rem"&&~t.indexOf("adius")||i==="em"&&e.appendChild&&!c?e:e.parentNode,p&&(_=(e.ownerSVGElement||{}).parentNode),(!_||_===Ji||!_.appendChild)&&(_=Ji.body),m=_._gsap,m&&f&&m.width&&l&&m.time===zn.time&&!m.uncache)return Ut(s/m.width*h);if(f&&(t==="height"||t==="width")){var T=e.style[t];e.style[t]=h+i,g=e[u],T?e.style[t]=T:ur(e,t)}else(f||a==="%")&&!nS[Vn(_,"display")]&&(o.position=Vn(e,"position")),_===e&&(o.position="static"),_.appendChild(Lr),g=Lr[u],_.removeChild(Lr),o.position="absolute";return l&&f&&(m=Ur(_),m.time=zn.time,m.width=_[u]),Ut(d?g*s/h:g&&s?h/g*s:0)},Ci=function(e,t,n,i){var s;return Ou||nu(),t in vi&&t!=="transform"&&(t=vi[t],~t.indexOf(",")&&(t=t.split(",")[0])),Vi[t]&&t!=="transform"?(s=Ra(e,i),s=t!=="transformOrigin"?s[t]:s.svg?s.origin:jo(Vn(e,Cn))+" "+s.zOrigin+"px"):(s=e.style[t],(!s||s==="auto"||i||~(s+"").indexOf("calc("))&&(s=Zo[t]&&Zo[t](e,t,n)||Vn(e,t)||yd(e,t)||(t==="opacity"?1:0))),n&&!~(s+"").trim().indexOf(" ")?fr(e,t,s,n)+n:s},iS=function(e,t,n,i){if(!n||n==="none"){var s=zs(t,e,1),a=s&&Vn(e,s,1);a&&a!==n?(t=s,n=a):t==="borderColor"&&(n=Vn(e,"borderTopColor"))}var o=new Rn(this._pt,e.style,t,0,1,jd),l=0,c=0,u,h,d,f,g,_,m,p,T,E,x,R;if(o.b=n,o.e=i,n+="",i+="",i.substring(0,6)==="var(--"&&(i=Vn(e,i.substring(4,i.indexOf(")")))),i==="auto"&&(_=e.style[t],e.style[t]=i,i=Vn(e,t)||i,_?e.style[t]=_:ur(e,t)),u=[n,i],Hd(u),n=u[0],i=u[1],d=n.match(ms)||[],R=i.match(ms)||[],R.length){for(;h=ms.exec(i);)m=h[0],T=i.substring(l,h.index),g?g=(g+1)%5:(T.substr(-5)==="rgba("||T.substr(-5)==="hsla(")&&(g=1),m!==(_=d[c++]||"")&&(f=parseFloat(_)||0,x=_.substr((f+"").length),m.charAt(1)==="="&&(m=Ss(f,m)+x),p=parseFloat(m),E=m.substr((p+"").length),l=ms.lastIndex-E.length,E||(E=E||Gn.units[t]||x,l===i.length&&(i+=E,o.e+=E)),x!==E&&(f=fr(e,t,_,E)||0),o._pt={_next:o._pt,p:T||c===1?T:",",s:f,c:p-f,m:g&&g<4||t==="zIndex"?Math.round:0});o.c=l<i.length?i.substring(l,i.length):""}else o.r=t==="display"&&i==="none"?tp:ep;return gd.test(i)&&(o.e=0),this._pt=o,o},hh={top:"0%",bottom:"100%",left:"0%",right:"100%",center:"50%"},rS=function(e){var t=e.split(" "),n=t[0],i=t[1]||"50%";return(n==="top"||n==="bottom"||i==="left"||i==="right")&&(e=n,n=i,i=e),t[0]=hh[n]||n,t[1]=hh[i]||i,t.join(" ")},sS=function(e,t){if(t.tween&&t.tween._time===t.tween._dur){var n=t.t,i=n.style,s=t.u,a=n._gsap,o,l,c;if(s==="all"||s===!0)i.cssText="",l=1;else for(s=s.split(","),c=s.length;--c>-1;)o=s[c],Vi[o]&&(l=1,o=o==="transformOrigin"?Cn:Rt),ur(n,o);l&&(ur(n,Rt),a&&(a.svg&&n.removeAttribute("transform"),i.scale=i.rotate=i.translate="none",Ra(n,1),a.uncache=1,np(i)))}},Zo={clearProps:function(e,t,n,i,s){if(s.data!=="isFromStart"){var a=e._pt=new Rn(e._pt,t,n,0,0,sS);return a.u=i,a.pr=-10,a.tween=s,e._props.push(n),1}}},wa=[1,0,0,1,0,0],op={},lp=function(e){return e==="matrix(1, 0, 0, 1, 0, 0)"||e==="none"||!e},dh=function(e){var t=Vn(e,Rt);return lp(t)?wa:t.substr(7).match(_d).map(Ut)},ku=function(e,t){var n=e._gsap||Ur(e),i=e.style,s=dh(e),a,o,l,c;return n.svg&&e.getAttribute("transform")?(l=e.transform.baseVal.consolidate().matrix,s=[l.a,l.b,l.c,l.d,l.e,l.f],s.join(",")==="1,0,0,1,0,0"?wa:s):(s===wa&&!e.offsetParent&&e!==ys&&!n.svg&&(l=i.display,i.display="block",a=e.parentNode,(!a||!e.offsetParent&&!e.getBoundingClientRect().width)&&(c=1,o=e.nextElementSibling,ys.appendChild(e)),s=dh(e),l?i.display=l:ur(e,"display"),c&&(o?a.insertBefore(e,o):a?a.appendChild(e):ys.removeChild(e))),t&&s.length>6?[s[0],s[1],s[4],s[5],s[12],s[13]]:s)},iu=function(e,t,n,i,s,a){var o=e._gsap,l=s||ku(e,!0),c=o.xOrigin||0,u=o.yOrigin||0,h=o.xOffset||0,d=o.yOffset||0,f=l[0],g=l[1],_=l[2],m=l[3],p=l[4],T=l[5],E=t.split(" "),x=parseFloat(E[0])||0,R=parseFloat(E[1])||0,w,b,C,M;n?l!==wa&&(b=f*m-g*_)&&(C=x*(m/b)+R*(-_/b)+(_*T-m*p)/b,M=x*(-g/b)+R*(f/b)-(f*T-g*p)/b,x=C,R=M):(w=sp(e),x=w.x+(~E[0].indexOf("%")?x/100*w.width:x),R=w.y+(~(E[1]||E[0]).indexOf("%")?R/100*w.height:R)),i||i!==!1&&o.smooth?(p=x-c,T=R-u,o.xOffset=h+(p*f+T*_)-p,o.yOffset=d+(p*g+T*m)-T):o.xOffset=o.yOffset=0,o.xOrigin=x,o.yOrigin=R,o.smooth=!!i,o.origin=t,o.originIsAbsolute=!!n,e.style[Cn]="0px 0px",a&&(Qi(a,o,"xOrigin",c,x),Qi(a,o,"yOrigin",u,R),Qi(a,o,"xOffset",h,o.xOffset),Qi(a,o,"yOffset",d,o.yOffset)),e.setAttribute("data-svg-origin",x+" "+R)},Ra=function(e,t){var n=e._gsap||new Xd(e);if("x"in n&&!t&&!n.uncache)return n;var i=e.style,s=n.scaleX<0,a="px",o="deg",l=getComputedStyle(e),c=Vn(e,Cn)||"0",u,h,d,f,g,_,m,p,T,E,x,R,w,b,C,M,v,P,U,O,G,Y,H,q,k,ne,D,ue,Ie,$e,K,te;return u=h=d=_=m=p=T=E=x=0,f=g=1,n.svg=!!(e.getCTM&&ap(e)),l.translate&&((l.translate!=="none"||l.scale!=="none"||l.rotate!=="none")&&(i[Rt]=(l.translate!=="none"?"translate3d("+(l.translate+" 0 0").split(" ").slice(0,3).join(", ")+") ":"")+(l.rotate!=="none"?"rotate("+l.rotate+") ":"")+(l.scale!=="none"?"scale("+l.scale.split(" ").join(",")+") ":"")+(l[Rt]!=="none"?l[Rt]:"")),i.scale=i.rotate=i.translate="none"),b=ku(e,n.svg),n.svg&&(n.uncache?(k=e.getBBox(),c=n.xOrigin-k.x+"px "+(n.yOrigin-k.y)+"px",q=""):q=!t&&e.getAttribute("data-svg-origin"),iu(e,q||c,!!q||n.originIsAbsolute,n.smooth!==!1,b)),R=n.xOrigin||0,w=n.yOrigin||0,b!==wa&&(P=b[0],U=b[1],O=b[2],G=b[3],u=Y=b[4],h=H=b[5],b.length===6?(f=Math.sqrt(P*P+U*U),g=Math.sqrt(G*G+O*O),_=P||U?ls(U,P)*br:0,T=O||G?ls(O,G)*br+_:0,T&&(g*=Math.abs(Math.cos(T*Es))),n.svg&&(u-=R-(R*P+w*O),h-=w-(R*U+w*G))):(te=b[6],$e=b[7],D=b[8],ue=b[9],Ie=b[10],K=b[11],u=b[12],h=b[13],d=b[14],C=ls(te,Ie),m=C*br,C&&(M=Math.cos(-C),v=Math.sin(-C),q=Y*M+D*v,k=H*M+ue*v,ne=te*M+Ie*v,D=Y*-v+D*M,ue=H*-v+ue*M,Ie=te*-v+Ie*M,K=$e*-v+K*M,Y=q,H=k,te=ne),C=ls(-O,Ie),p=C*br,C&&(M=Math.cos(-C),v=Math.sin(-C),q=P*M-D*v,k=U*M-ue*v,ne=O*M-Ie*v,K=G*v+K*M,P=q,U=k,O=ne),C=ls(U,P),_=C*br,C&&(M=Math.cos(C),v=Math.sin(C),q=P*M+U*v,k=Y*M+H*v,U=U*M-P*v,H=H*M-Y*v,P=q,Y=k),m&&Math.abs(m)+Math.abs(_)>359.9&&(m=_=0,p=180-p),f=Ut(Math.sqrt(P*P+U*U+O*O)),g=Ut(Math.sqrt(H*H+te*te)),C=ls(Y,H),T=Math.abs(C)>2e-4?C*br:0,x=K?1/(K<0?-K:K):0),n.svg&&(q=e.getAttribute("transform"),n.forceCSS=e.setAttribute("transform","")||!lp(Vn(e,Rt)),q&&e.setAttribute("transform",q))),Math.abs(T)>90&&Math.abs(T)<270&&(s?(f*=-1,T+=_<=0?180:-180,_+=_<=0?180:-180):(g*=-1,T+=T<=0?180:-180)),t=t||n.uncache,n.x=u-((n.xPercent=u&&(!t&&n.xPercent||(Math.round(e.offsetWidth/2)===Math.round(-u)?-50:0)))?e.offsetWidth*n.xPercent/100:0)+a,n.y=h-((n.yPercent=h&&(!t&&n.yPercent||(Math.round(e.offsetHeight/2)===Math.round(-h)?-50:0)))?e.offsetHeight*n.yPercent/100:0)+a,n.z=d+a,n.scaleX=Ut(f),n.scaleY=Ut(g),n.rotation=Ut(_)+o,n.rotationX=Ut(m)+o,n.rotationY=Ut(p)+o,n.skewX=T+o,n.skewY=E+o,n.transformPerspective=x+a,(n.zOrigin=parseFloat(c.split(" ")[2])||!t&&n.zOrigin||0)&&(i[Cn]=jo(c)),n.xOffset=n.yOffset=0,n.force3D=Gn.force3D,n.renderTransform=n.svg?oS:rp?cp:aS,n.uncache=0,n},jo=function(e){return(e=e.split(" "))[0]+" "+e[1]},$l=function(e,t,n){var i=an(t);return Ut(parseFloat(t)+parseFloat(fr(e,"x",n+"px",i)))+i},aS=function(e,t){t.z="0px",t.rotationY=t.rotationX="0deg",t.force3D=0,cp(e,t)},Sr="0deg",js="0px",yr=") ",cp=function(e,t){var n=t||this,i=n.xPercent,s=n.yPercent,a=n.x,o=n.y,l=n.z,c=n.rotation,u=n.rotationY,h=n.rotationX,d=n.skewX,f=n.skewY,g=n.scaleX,_=n.scaleY,m=n.transformPerspective,p=n.force3D,T=n.target,E=n.zOrigin,x="",R=p==="auto"&&e&&e!==1||p===!0;if(E&&(h!==Sr||u!==Sr)){var w=parseFloat(u)*Es,b=Math.sin(w),C=Math.cos(w),M;w=parseFloat(h)*Es,M=Math.cos(w),a=$l(T,a,b*M*-E),o=$l(T,o,-Math.sin(w)*-E),l=$l(T,l,C*M*-E+E)}m!==js&&(x+="perspective("+m+yr),(i||s)&&(x+="translate("+i+"%, "+s+"%) "),(R||a!==js||o!==js||l!==js)&&(x+=l!==js||R?"translate3d("+a+", "+o+", "+l+") ":"translate("+a+", "+o+yr),c!==Sr&&(x+="rotate("+c+yr),u!==Sr&&(x+="rotateY("+u+yr),h!==Sr&&(x+="rotateX("+h+yr),(d!==Sr||f!==Sr)&&(x+="skew("+d+", "+f+yr),(g!==1||_!==1)&&(x+="scale("+g+", "+_+yr),T.style[Rt]=x||"translate(0, 0)"},oS=function(e,t){var n=t||this,i=n.xPercent,s=n.yPercent,a=n.x,o=n.y,l=n.rotation,c=n.skewX,u=n.skewY,h=n.scaleX,d=n.scaleY,f=n.target,g=n.xOrigin,_=n.yOrigin,m=n.xOffset,p=n.yOffset,T=n.forceCSS,E=parseFloat(a),x=parseFloat(o),R,w,b,C,M;l=parseFloat(l),c=parseFloat(c),u=parseFloat(u),u&&(u=parseFloat(u),c+=u,l+=u),l||c?(l*=Es,c*=Es,R=Math.cos(l)*h,w=Math.sin(l)*h,b=Math.sin(l-c)*-d,C=Math.cos(l-c)*d,c&&(u*=Es,M=Math.tan(c-u),M=Math.sqrt(1+M*M),b*=M,C*=M,u&&(M=Math.tan(u),M=Math.sqrt(1+M*M),R*=M,w*=M)),R=Ut(R),w=Ut(w),b=Ut(b),C=Ut(C)):(R=h,C=d,w=b=0),(E&&!~(a+"").indexOf("px")||x&&!~(o+"").indexOf("px"))&&(E=fr(f,"x",a,"px"),x=fr(f,"y",o,"px")),(g||_||m||p)&&(E=Ut(E+g-(g*R+_*b)+m),x=Ut(x+_-(g*w+_*C)+p)),(i||s)&&(M=f.getBBox(),E=Ut(E+i/100*M.width),x=Ut(x+s/100*M.height)),M="matrix("+R+","+w+","+b+","+C+","+E+","+x+")",f.setAttribute("transform",M),T&&(f.style[Rt]=M)},lS=function(e,t,n,i,s){var a=360,o=jt(s),l=parseFloat(s)*(o&&~s.indexOf("rad")?br:1),c=l-i,u=i+c+"deg",h,d;return o&&(h=s.split("_")[1],h==="short"&&(c%=a,c!==c%(a/2)&&(c+=c<0?a:-a)),h==="cw"&&c<0?c=(c+a*oh)%a-~~(c/a)*a:h==="ccw"&&c>0&&(c=(c-a*oh)%a-~~(c/a)*a)),e._pt=d=new Rn(e._pt,t,n,i,c,WM),d.e=u,d.u="deg",e._props.push(n),d},ph=function(e,t){for(var n in t)e[n]=t[n];return e},cS=function(e,t,n){var i=ph({},n._gsap),s="perspective,force3D,transformOrigin,svgOrigin",a=n.style,o,l,c,u,h,d,f,g;i.svg?(c=n.getAttribute("transform"),n.setAttribute("transform",""),a[Rt]=t,o=Ra(n,1),ur(n,Rt),n.setAttribute("transform",c)):(c=getComputedStyle(n)[Rt],a[Rt]=t,o=Ra(n,1),a[Rt]=c);for(l in Vi)c=i[l],u=o[l],c!==u&&s.indexOf(l)<0&&(f=an(c),g=an(u),h=f!==g?fr(n,l,c,g):parseFloat(c),d=parseFloat(u),e._pt=new Rn(e._pt,o,l,h,d-h,eu),e._pt.u=g||0,e._props.push(l));ph(o,i)};wn("padding,margin,Width,Radius",function(r,e){var t="Top",n="Right",i="Bottom",s="Left",a=(e<3?[t,n,i,s]:[t+s,t+n,i+n,i+s]).map(function(o){return e<2?r+o:"border"+o+r});Zo[e>1?"border"+r:r]=function(o,l,c,u,h){var d,f;if(arguments.length<4)return d=a.map(function(g){return Ci(o,g,c)}),f=d.join(" "),f.split(d[0]).length===5?d[0]:f;d=(u+"").split(" "),f={},a.forEach(function(g,_){return f[g]=d[_]=d[_]||d[(_-1)/2|0]}),o.init(l,f,h)}});var up={name:"css",register:nu,targetTest:function(e){return e.style&&e.nodeType},init:function(e,t,n,i,s){var a=this._props,o=e.style,l=n.vars.startAt,c,u,h,d,f,g,_,m,p,T,E,x,R,w,b,C,M;Ou||nu(),this.styles=this.styles||ip(e),C=this.styles.props,this.tween=n;for(_ in t)if(_!=="autoRound"&&(u=t[_],!(On[_]&&qd(_,t,n,i,e,s)))){if(f=typeof u,g=Zo[_],f==="function"&&(u=u.call(n,i,e,s),f=typeof u),f==="string"&&~u.indexOf("random(")&&(u=Ta(u)),g)g(this,e,_,u,n)&&(b=1);else if(_.substr(0,2)==="--")c=(getComputedStyle(e).getPropertyValue(_)+"").trim(),u+="",sr.lastIndex=0,sr.test(c)||(m=an(c),p=an(u),p?m!==p&&(c=fr(e,_,c,p)+p):m&&(u+=m)),this.add(o,"setProperty",c,u,i,s,0,0,_),a.push(_),C.push(_,0,o[_]);else if(f!=="undefined"){if(l&&_ in l?(c=typeof l[_]=="function"?l[_].call(n,i,e,s):l[_],jt(c)&&~c.indexOf("random(")&&(c=Ta(c)),an(c+"")||c==="auto"||(c+=Gn.units[_]||an(Ci(e,_))||""),(c+"").charAt(1)==="="&&(c=Ci(e,_))):c=Ci(e,_),d=parseFloat(c),T=f==="string"&&u.charAt(1)==="="&&u.substr(0,2),T&&(u=u.substr(2)),h=parseFloat(u),_ in vi&&(_==="autoAlpha"&&(d===1&&Ci(e,"visibility")==="hidden"&&h&&(d=0),C.push("visibility",0,o.visibility),Qi(this,o,"visibility",d?"inherit":"hidden",h?"inherit":"hidden",!h)),_!=="scale"&&_!=="transform"&&(_=vi[_],~_.indexOf(",")&&(_=_.split(",")[0]))),E=_ in Vi,E){if(this.styles.save(_),M=u,f==="string"&&u.substring(0,6)==="var(--"){if(u=Vn(e,u.substring(4,u.indexOf(")"))),u.substring(0,5)==="calc("){var v=e.style.perspective;e.style.perspective=u,u=Vn(e,"perspective"),v?e.style.perspective=v:ur(e,"perspective")}h=parseFloat(u)}if(x||(R=e._gsap,R.renderTransform&&!t.parseTransform||Ra(e,t.parseTransform),w=t.smoothOrigin!==!1&&R.smooth,x=this._pt=new Rn(this._pt,o,Rt,0,1,R.renderTransform,R,0,-1),x.dep=1),_==="scale")this._pt=new Rn(this._pt,R,"scaleY",R.scaleY,(T?Ss(R.scaleY,T+h):h)-R.scaleY||0,eu),this._pt.u=0,a.push("scaleY",_),_+="X";else if(_==="transformOrigin"){C.push(Cn,0,o[Cn]),u=rS(u),R.svg?iu(e,u,0,w,0,this):(p=parseFloat(u.split(" ")[2])||0,p!==R.zOrigin&&Qi(this,R,"zOrigin",R.zOrigin,p),Qi(this,o,_,jo(c),jo(u)));continue}else if(_==="svgOrigin"){iu(e,u,1,w,0,this);continue}else if(_ in op){lS(this,R,_,d,T?Ss(d,T+u):u);continue}else if(_==="smoothOrigin"){Qi(this,R,"smooth",R.smooth,u);continue}else if(_==="force3D"){R[_]=u;continue}else if(_==="transform"){cS(this,u,e);continue}}else _ in o||(_=zs(_)||_);if(E||(h||h===0)&&(d||d===0)&&!GM.test(u)&&_ in o)m=(c+"").substr((d+"").length),h||(h=0),p=an(u)||(_ in Gn.units?Gn.units[_]:m),m!==p&&(d=fr(e,_,c,p)),this._pt=new Rn(this._pt,E?R:o,_,d,(T?Ss(d,T+h):h)-d,!E&&(p==="px"||_==="zIndex")&&t.autoRound!==!1?YM:eu),this._pt.u=p||0,E&&M!==u?(this._pt.b=c,this._pt.e=M,this._pt.r=qM):m!==p&&p!=="%"&&(this._pt.b=c,this._pt.r=XM);else if(_ in o)iS.call(this,e,_,c,T?T+u:u);else if(_ in e)this.add(e,_,c||e[_],T?T+u:u,i,s);else if(_!=="parseTransform"){wu(_,u);continue}E||(_ in o?C.push(_,0,o[_]):typeof e[_]=="function"?C.push(_,2,e[_]()):C.push(_,1,c||e[_])),a.push(_)}}b&&Jd(this)},render:function(e,t){if(t.tween._time||!Bu())for(var n=t._pt;n;)n.r(e,n.d),n=n._next;else t.styles.revert()},get:Ci,aliases:vi,getSetter:function(e,t,n){var i=vi[t];return i&&i.indexOf(",")<0&&(t=i),t in Vi&&t!==Cn&&(e._gsap.x||Ci(e,"x"))?n&&ah===n?t==="scale"?jM:ZM:(ah=n||{})&&(t==="scale"?JM:QM):e.style&&!Tu(e.style[t])?$M:~t.indexOf("-")?KM:Nu(e,t)},core:{_removeProperty:ur,_getMatrix:ku}};Pn.utils.checkPrefix=zs;Pn.core.getStyleSaver=ip;(function(r,e,t,n){var i=wn(r+","+e+","+t,function(s){Vi[s]=1});wn(e,function(s){Gn.units[s]="deg",op[s]=1}),vi[i[13]]=r+","+e,wn(n,function(s){var a=s.split(":");vi[a[1]]=i[a[0]]})})("x,y,z,scale,scaleX,scaleY,xPercent,yPercent","rotation,rotationX,rotationY,skewX,skewY","transform,transformOrigin,svgOrigin,force3D,smoothOrigin,transformPerspective","0:translateX,1:translateY,2:translateZ,8:rotate,8:rotationZ,8:rotateZ,9:rotateX,10:rotateY");wn("x,y,z,top,right,bottom,left,width,height,fontSize,padding,margin,perspective",function(r){Gn.units[r]="px"});Pn.registerPlugin(up);var Ht=Pn.registerPlugin(up)||Pn;Ht.core.Tween;function uS(r,e){for(var t=0;t<e.length;t++){var n=e[t];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(r,n.key,n)}}function fS(r,e,t){return e&&uS(r.prototype,e),r}/*!
 * Observer 3.14.2
 * https://gsap.com
 *
 * @license Copyright 2008-2025, GreenSock. All rights reserved.
 * Subject to the terms at https://gsap.com/standard-license
 * @author: Jack Doyle, jack@greensock.com
*/var Qt,Io,kn,er,tr,Ts,fp,Ar,fa,hp,Ni,li,dp,pp=function(){return Qt||typeof window<"u"&&(Qt=window.gsap)&&Qt.registerPlugin&&Qt},mp=1,gs=[],tt=[],Mi=[],ha=Date.now,ru=function(e,t){return t},hS=function(){var e=fa.core,t=e.bridge||{},n=e._scrollers,i=e._proxies;n.push.apply(n,tt),i.push.apply(i,Mi),tt=n,Mi=i,ru=function(a,o){return t[a](o)}},ar=function(e,t){return~Mi.indexOf(e)&&Mi[Mi.indexOf(e)+1][t]},da=function(e){return!!~hp.indexOf(e)},hn=function(e,t,n,i,s){return e.addEventListener(t,n,{passive:i!==!1,capture:!!s})},fn=function(e,t,n,i){return e.removeEventListener(t,n,!!i)},fo="scrollLeft",ho="scrollTop",su=function(){return Ni&&Ni.isPressed||tt.cache++},Jo=function(e,t){var n=function i(s){if(s||s===0){mp&&(kn.history.scrollRestoration="manual");var a=Ni&&Ni.isPressed;s=i.v=Math.round(s)||(Ni&&Ni.iOS?1:0),e(s),i.cacheID=tt.cache,a&&ru("ss",s)}else(t||tt.cache!==i.cacheID||ru("ref"))&&(i.cacheID=tt.cache,i.v=e());return i.v+i.offset};return n.offset=0,e&&n},vn={s:fo,p:"left",p2:"Left",os:"right",os2:"Right",d:"width",d2:"Width",a:"x",sc:Jo(function(r){return arguments.length?kn.scrollTo(r,Xt.sc()):kn.pageXOffset||er[fo]||tr[fo]||Ts[fo]||0})},Xt={s:ho,p:"top",p2:"Top",os:"bottom",os2:"Bottom",d:"height",d2:"Height",a:"y",op:vn,sc:Jo(function(r){return arguments.length?kn.scrollTo(vn.sc(),r):kn.pageYOffset||er[ho]||tr[ho]||Ts[ho]||0})},yn=function(e,t){return(t&&t._ctx&&t._ctx.selector||Qt.utils.toArray)(e)[0]||(typeof e=="string"&&Qt.config().nullTargetWarn!==!1?console.warn("Element not found:",e):null)},dS=function(e,t){for(var n=t.length;n--;)if(t[n]===e||t[n].contains(e))return!0;return!1},hr=function(e,t){var n=t.s,i=t.sc;da(e)&&(e=er.scrollingElement||tr);var s=tt.indexOf(e),a=i===Xt.sc?1:2;!~s&&(s=tt.push(e)-1),tt[s+a]||hn(e,"scroll",su);var o=tt[s+a],l=o||(tt[s+a]=Jo(ar(e,n),!0)||(da(e)?i:Jo(function(c){return arguments.length?e[n]=c:e[n]})));return l.target=e,o||(l.smooth=Qt.getProperty(e,"scrollBehavior")==="smooth"),l},au=function(e,t,n){var i=e,s=e,a=ha(),o=a,l=t||50,c=Math.max(500,l*3),u=function(g,_){var m=ha();_||m-a>l?(s=i,i=g,o=a,a=m):n?i+=g:i=s+(g-s)/(m-o)*(a-o)},h=function(){s=i=n?0:i,o=a=0},d=function(g){var _=o,m=s,p=ha();return(g||g===0)&&g!==i&&u(g),a===o||p-o>c?0:(i+(n?m:-m))/((n?p:a)-_)*1e3};return{update:u,reset:h,getVelocity:d}},Js=function(e,t){return t&&!e._gsapAllow&&e.preventDefault(),e.changedTouches?e.changedTouches[0]:e},mh=function(e){var t=Math.max.apply(Math,e),n=Math.min.apply(Math,e);return Math.abs(t)>=Math.abs(n)?t:n},_p=function(){fa=Qt.core.globals().ScrollTrigger,fa&&fa.core&&hS()},gp=function(e){return Qt=e||pp(),!Io&&Qt&&typeof document<"u"&&document.body&&(kn=window,er=document,tr=er.documentElement,Ts=er.body,hp=[kn,er,tr,Ts],Qt.utils.clamp,dp=Qt.core.context||function(){},Ar="onpointerenter"in Ts?"pointer":"mouse",fp=Ft.isTouch=kn.matchMedia&&kn.matchMedia("(hover: none), (pointer: coarse)").matches?1:"ontouchstart"in kn||navigator.maxTouchPoints>0||navigator.msMaxTouchPoints>0?2:0,li=Ft.eventTypes=("ontouchstart"in tr?"touchstart,touchmove,touchcancel,touchend":"onpointerdown"in tr?"pointerdown,pointermove,pointercancel,pointerup":"mousedown,mousemove,mouseup,mouseup").split(","),setTimeout(function(){return mp=0},500),_p(),Io=1),Io};vn.op=Xt;tt.cache=0;var Ft=function(){function r(t){this.init(t)}var e=r.prototype;return e.init=function(n){Io||gp(Qt)||console.warn("Please gsap.registerPlugin(Observer)"),fa||_p();var i=n.tolerance,s=n.dragMinimum,a=n.type,o=n.target,l=n.lineHeight,c=n.debounce,u=n.preventDefault,h=n.onStop,d=n.onStopDelay,f=n.ignore,g=n.wheelSpeed,_=n.event,m=n.onDragStart,p=n.onDragEnd,T=n.onDrag,E=n.onPress,x=n.onRelease,R=n.onRight,w=n.onLeft,b=n.onUp,C=n.onDown,M=n.onChangeX,v=n.onChangeY,P=n.onChange,U=n.onToggleX,O=n.onToggleY,G=n.onHover,Y=n.onHoverEnd,H=n.onMove,q=n.ignoreCheck,k=n.isNormalizer,ne=n.onGestureStart,D=n.onGestureEnd,ue=n.onWheel,Ie=n.onEnable,$e=n.onDisable,K=n.onClick,te=n.scrollSpeed,_e=n.capture,ie=n.allowClicks,Ee=n.lockAxis,we=n.onLockAxis;this.target=o=yn(o)||tr,this.vars=n,f&&(f=Qt.utils.toArray(f)),i=i||1e-9,s=s||0,g=g||1,te=te||1,a=a||"wheel,touch,pointer",c=c!==!1,l||(l=parseFloat(kn.getComputedStyle(Ts).lineHeight)||22);var He,Ke,Fe,Ce,I,mt,Be,B=this,Me=0,rt=0,Te=n.passive||!u&&n.passive!==!1,A=hr(o,vn),S=hr(o,Xt),z=A(),Q=S(),J=~a.indexOf("touch")&&!~a.indexOf("pointer")&&li[0]==="pointerdown",Z=da(o),fe=o.ownerDocument||er,ae=[0,0,0],de=[0,0,0],Ge=0,re=function(){return Ge=ha()},se=function(be,Xe){return(B.event=be)&&f&&dS(be.target,f)||Xe&&J&&be.pointerType!=="touch"||q&&q(be,Xe)},Le=function(){B._vx.reset(),B._vy.reset(),Ke.pause(),h&&h(B)},Pe=function(){var be=B.deltaX=mh(ae),Xe=B.deltaY=mh(de),pe=Math.abs(be)>=i,Ve=Math.abs(Xe)>=i;P&&(pe||Ve)&&P(B,be,Xe,ae,de),pe&&(R&&B.deltaX>0&&R(B),w&&B.deltaX<0&&w(B),M&&M(B),U&&B.deltaX<0!=Me<0&&U(B),Me=B.deltaX,ae[0]=ae[1]=ae[2]=0),Ve&&(C&&B.deltaY>0&&C(B),b&&B.deltaY<0&&b(B),v&&v(B),O&&B.deltaY<0!=rt<0&&O(B),rt=B.deltaY,de[0]=de[1]=de[2]=0),(Ce||Fe)&&(H&&H(B),Fe&&(m&&Fe===1&&m(B),T&&T(B),Fe=0),Ce=!1),mt&&!(mt=!1)&&we&&we(B),I&&(ue(B),I=!1),He=0},ve=function(be,Xe,pe){ae[pe]+=be,de[pe]+=Xe,B._vx.update(be),B._vy.update(Xe),c?He||(He=requestAnimationFrame(Pe)):Pe()},We=function(be,Xe){Ee&&!Be&&(B.axis=Be=Math.abs(be)>Math.abs(Xe)?"x":"y",mt=!0),Be!=="y"&&(ae[2]+=be,B._vx.update(be,!0)),Be!=="x"&&(de[2]+=Xe,B._vy.update(Xe,!0)),c?He||(He=requestAnimationFrame(Pe)):Pe()},Oe=function(be){if(!se(be,1)){be=Js(be,u);var Xe=be.clientX,pe=be.clientY,Ve=Xe-B.x,Ae=pe-B.y,ke=B.isDragging;B.x=Xe,B.y=pe,(ke||(Ve||Ae)&&(Math.abs(B.startX-Xe)>=s||Math.abs(B.startY-pe)>=s))&&(Fe||(Fe=ke?2:1),ke||(B.isDragging=!0),We(Ve,Ae))}},ot=B.onPress=function(ge){se(ge,1)||ge&&ge.button||(B.axis=Be=null,Ke.pause(),B.isPressed=!0,ge=Js(ge),Me=rt=0,B.startX=B.x=ge.clientX,B.startY=B.y=ge.clientY,B._vx.reset(),B._vy.reset(),hn(k?o:fe,li[1],Oe,Te,!0),B.deltaX=B.deltaY=0,E&&E(B))},L=B.onRelease=function(ge){if(!se(ge,1)){fn(k?o:fe,li[1],Oe,!0);var be=!isNaN(B.y-B.startY),Xe=B.isDragging,pe=Xe&&(Math.abs(B.x-B.startX)>3||Math.abs(B.y-B.startY)>3),Ve=Js(ge);!pe&&be&&(B._vx.reset(),B._vy.reset(),u&&ie&&Qt.delayedCall(.08,function(){if(ha()-Ge>300&&!ge.defaultPrevented){if(ge.target.click)ge.target.click();else if(fe.createEvent){var Ae=fe.createEvent("MouseEvents");Ae.initMouseEvent("click",!0,!0,kn,1,Ve.screenX,Ve.screenY,Ve.clientX,Ve.clientY,!1,!1,!1,!1,0,null),ge.target.dispatchEvent(Ae)}}})),B.isDragging=B.isGesturing=B.isPressed=!1,h&&Xe&&!k&&Ke.restart(!0),Fe&&Pe(),p&&Xe&&p(B),x&&x(B,pe)}},ce=function(be){return be.touches&&be.touches.length>1&&(B.isGesturing=!0)&&ne(be,B.isDragging)},$=function(){return(B.isGesturing=!1)||D(B)},j=function(be){if(!se(be)){var Xe=A(),pe=S();ve((Xe-z)*te,(pe-Q)*te,1),z=Xe,Q=pe,h&&Ke.restart(!0)}},le=function(be){if(!se(be)){be=Js(be,u),ue&&(I=!0);var Xe=(be.deltaMode===1?l:be.deltaMode===2?kn.innerHeight:1)*g;ve(be.deltaX*Xe,be.deltaY*Xe,0),h&&!k&&Ke.restart(!0)}},he=function(be){if(!se(be)){var Xe=be.clientX,pe=be.clientY,Ve=Xe-B.x,Ae=pe-B.y;B.x=Xe,B.y=pe,Ce=!0,h&&Ke.restart(!0),(Ve||Ae)&&We(Ve,Ae)}},ze=function(be){B.event=be,G(B)},lt=function(be){B.event=be,Y(B)},Ct=function(be){return se(be)||Js(be,u)&&K(B)};Ke=B._dc=Qt.delayedCall(d||.25,Le).pause(),B.deltaX=B.deltaY=0,B._vx=au(0,50,!0),B._vy=au(0,50,!0),B.scrollX=A,B.scrollY=S,B.isDragging=B.isGesturing=B.isPressed=!1,dp(this),B.enable=function(ge){return B.isEnabled||(hn(Z?fe:o,"scroll",su),a.indexOf("scroll")>=0&&hn(Z?fe:o,"scroll",j,Te,_e),a.indexOf("wheel")>=0&&hn(o,"wheel",le,Te,_e),(a.indexOf("touch")>=0&&fp||a.indexOf("pointer")>=0)&&(hn(o,li[0],ot,Te,_e),hn(fe,li[2],L),hn(fe,li[3],L),ie&&hn(o,"click",re,!0,!0),K&&hn(o,"click",Ct),ne&&hn(fe,"gesturestart",ce),D&&hn(fe,"gestureend",$),G&&hn(o,Ar+"enter",ze),Y&&hn(o,Ar+"leave",lt),H&&hn(o,Ar+"move",he)),B.isEnabled=!0,B.isDragging=B.isGesturing=B.isPressed=Ce=Fe=!1,B._vx.reset(),B._vy.reset(),z=A(),Q=S(),ge&&ge.type&&ot(ge),Ie&&Ie(B)),B},B.disable=function(){B.isEnabled&&(gs.filter(function(ge){return ge!==B&&da(ge.target)}).length||fn(Z?fe:o,"scroll",su),B.isPressed&&(B._vx.reset(),B._vy.reset(),fn(k?o:fe,li[1],Oe,!0)),fn(Z?fe:o,"scroll",j,_e),fn(o,"wheel",le,_e),fn(o,li[0],ot,_e),fn(fe,li[2],L),fn(fe,li[3],L),fn(o,"click",re,!0),fn(o,"click",Ct),fn(fe,"gesturestart",ce),fn(fe,"gestureend",$),fn(o,Ar+"enter",ze),fn(o,Ar+"leave",lt),fn(o,Ar+"move",he),B.isEnabled=B.isPressed=B.isDragging=!1,$e&&$e(B))},B.kill=B.revert=function(){B.disable();var ge=gs.indexOf(B);ge>=0&&gs.splice(ge,1),Ni===B&&(Ni=0)},gs.push(B),k&&da(o)&&(Ni=B),B.enable(_)},fS(r,[{key:"velocityX",get:function(){return this._vx.getVelocity()}},{key:"velocityY",get:function(){return this._vy.getVelocity()}}]),r}();Ft.version="3.14.2";Ft.create=function(r){return new Ft(r)};Ft.register=gp;Ft.getAll=function(){return gs.slice()};Ft.getById=function(r){return gs.filter(function(e){return e.vars.id===r})[0]};pp()&&Qt.registerPlugin(Ft);/*!
 * ScrollTrigger 3.14.2
 * https://gsap.com
 *
 * @license Copyright 2008-2025, GreenSock. All rights reserved.
 * Subject to the terms at https://gsap.com/standard-license
 * @author: Jack Doyle, jack@greensock.com
*/var Se,hs,et,yt,Bn,dt,Hu,Qo,Ca,pa,ia,po,rn,ll,ou,mn,_h,gh,ds,vp,Kl,xp,pn,lu,Mp,Sp,Ki,cu,Vu,bs,Gu,ma,uu,Zl,mo=1,sn=Date.now,jl=sn(),ii=0,ra=0,vh=function(e,t,n){var i=Fn(e)&&(e.substr(0,6)==="clamp("||e.indexOf("max")>-1);return n["_"+t+"Clamp"]=i,i?e.substr(6,e.length-7):e},xh=function(e,t){return t&&(!Fn(e)||e.substr(0,6)!=="clamp(")?"clamp("+e+")":e},pS=function r(){return ra&&requestAnimationFrame(r)},Mh=function(){return ll=1},Sh=function(){return ll=0},pi=function(e){return e},sa=function(e){return Math.round(e*1e5)/1e5||0},yp=function(){return typeof window<"u"},Ep=function(){return Se||yp()&&(Se=window.gsap)&&Se.registerPlugin&&Se},Gr=function(e){return!!~Hu.indexOf(e)},Tp=function(e){return(e==="Height"?Gu:et["inner"+e])||Bn["client"+e]||dt["client"+e]},bp=function(e){return ar(e,"getBoundingClientRect")||(Gr(e)?function(){return Bo.width=et.innerWidth,Bo.height=Gu,Bo}:function(){return Di(e)})},mS=function(e,t,n){var i=n.d,s=n.d2,a=n.a;return(a=ar(e,"getBoundingClientRect"))?function(){return a()[i]}:function(){return(t?Tp(s):e["client"+s])||0}},_S=function(e,t){return!t||~Mi.indexOf(e)?bp(e):function(){return Bo}},xi=function(e,t){var n=t.s,i=t.d2,s=t.d,a=t.a;return Math.max(0,(n="scroll"+i)&&(a=ar(e,n))?a()-bp(e)()[s]:Gr(e)?(Bn[n]||dt[n])-Tp(i):e[n]-e["offset"+i])},_o=function(e,t){for(var n=0;n<ds.length;n+=3)(!t||~t.indexOf(ds[n+1]))&&e(ds[n],ds[n+1],ds[n+2])},Fn=function(e){return typeof e=="string"},on=function(e){return typeof e=="function"},aa=function(e){return typeof e=="number"},wr=function(e){return typeof e=="object"},Qs=function(e,t,n){return e&&e.progress(t?0:1)&&n&&e.pause()},Jl=function(e,t){if(e.enabled){var n=e._ctx?e._ctx.add(function(){return t(e)}):t(e);n&&n.totalTime&&(e.callbackAnimation=n)}},cs=Math.abs,Ap="left",wp="top",Wu="right",Xu="bottom",Br="width",zr="height",_a="Right",ga="Left",va="Top",xa="Bottom",zt="padding",Qn="margin",ks="Width",qu="Height",Wt="px",ei=function(e){return et.getComputedStyle(e)},gS=function(e){var t=ei(e).position;e.style.position=t==="absolute"||t==="fixed"?t:"relative"},yh=function(e,t){for(var n in t)n in e||(e[n]=t[n]);return e},Di=function(e,t){var n=t&&ei(e)[ou]!=="matrix(1, 0, 0, 1, 0, 0)"&&Se.to(e,{x:0,y:0,xPercent:0,yPercent:0,rotation:0,rotationX:0,rotationY:0,scale:1,skewX:0,skewY:0}).progress(1),i=e.getBoundingClientRect();return n&&n.progress(0).kill(),i},el=function(e,t){var n=t.d2;return e["offset"+n]||e["client"+n]||0},Rp=function(e){var t=[],n=e.labels,i=e.duration(),s;for(s in n)t.push(n[s]/i);return t},vS=function(e){return function(t){return Se.utils.snap(Rp(e),t)}},Yu=function(e){var t=Se.utils.snap(e),n=Array.isArray(e)&&e.slice(0).sort(function(i,s){return i-s});return n?function(i,s,a){a===void 0&&(a=.001);var o;if(!s)return t(i);if(s>0){for(i-=a,o=0;o<n.length;o++)if(n[o]>=i)return n[o];return n[o-1]}else for(o=n.length,i+=a;o--;)if(n[o]<=i)return n[o];return n[0]}:function(i,s,a){a===void 0&&(a=.001);var o=t(i);return!s||Math.abs(o-i)<a||o-i<0==s<0?o:t(s<0?i-e:i+e)}},xS=function(e){return function(t,n){return Yu(Rp(e))(t,n.direction)}},go=function(e,t,n,i){return n.split(",").forEach(function(s){return e(t,s,i)})},Zt=function(e,t,n,i,s){return e.addEventListener(t,n,{passive:!i,capture:!!s})},Kt=function(e,t,n,i){return e.removeEventListener(t,n,!!i)},vo=function(e,t,n){n=n&&n.wheelHandler,n&&(e(t,"wheel",n),e(t,"touchmove",n))},Eh={startColor:"green",endColor:"red",indent:0,fontSize:"16px",fontWeight:"normal"},xo={toggleActions:"play",anticipatePin:0},tl={top:0,left:0,center:.5,bottom:1,right:1},Uo=function(e,t){if(Fn(e)){var n=e.indexOf("="),i=~n?+(e.charAt(n-1)+1)*parseFloat(e.substr(n+1)):0;~n&&(e.indexOf("%")>n&&(i*=t/100),e=e.substr(0,n-1)),e=i+(e in tl?tl[e]*t:~e.indexOf("%")?parseFloat(e)*t/100:parseFloat(e)||0)}return e},Mo=function(e,t,n,i,s,a,o,l){var c=s.startColor,u=s.endColor,h=s.fontSize,d=s.indent,f=s.fontWeight,g=yt.createElement("div"),_=Gr(n)||ar(n,"pinType")==="fixed",m=e.indexOf("scroller")!==-1,p=_?dt:n,T=e.indexOf("start")!==-1,E=T?c:u,x="border-color:"+E+";font-size:"+h+";color:"+E+";font-weight:"+f+";pointer-events:none;white-space:nowrap;font-family:sans-serif,Arial;z-index:1000;padding:4px 8px;border-width:0;border-style:solid;";return x+="position:"+((m||l)&&_?"fixed;":"absolute;"),(m||l||!_)&&(x+=(i===Xt?Wu:Xu)+":"+(a+parseFloat(d))+"px;"),o&&(x+="box-sizing:border-box;text-align:left;width:"+o.offsetWidth+"px;"),g._isStart=T,g.setAttribute("class","gsap-marker-"+e+(t?" marker-"+t:"")),g.style.cssText=x,g.innerText=t||t===0?e+"-"+t:e,p.children[0]?p.insertBefore(g,p.children[0]):p.appendChild(g),g._offset=g["offset"+i.op.d2],No(g,0,i,T),g},No=function(e,t,n,i){var s={display:"block"},a=n[i?"os2":"p2"],o=n[i?"p2":"os2"];e._isFlipped=i,s[n.a+"Percent"]=i?-100:0,s[n.a]=i?"1px":0,s["border"+a+ks]=1,s["border"+o+ks]=0,s[n.p]=t+"px",Se.set(e,s)},je=[],fu={},Pa,Th=function(){return sn()-ii>34&&(Pa||(Pa=requestAnimationFrame(Bi)))},us=function(){(!pn||!pn.isPressed||pn.startX>dt.clientWidth)&&(tt.cache++,pn?Pa||(Pa=requestAnimationFrame(Bi)):Bi(),ii||Xr("scrollStart"),ii=sn())},Ql=function(){Sp=et.innerWidth,Mp=et.innerHeight},oa=function(e){tt.cache++,(e===!0||!rn&&!xp&&!yt.fullscreenElement&&!yt.webkitFullscreenElement&&(!lu||Sp!==et.innerWidth||Math.abs(et.innerHeight-Mp)>et.innerHeight*.25))&&Qo.restart(!0)},Wr={},MS=[],Cp=function r(){return Kt(it,"scrollEnd",r)||Ir(!0)},Xr=function(e){return Wr[e]&&Wr[e].map(function(t){return t()})||MS},Nn=[],Pp=function(e){for(var t=0;t<Nn.length;t+=5)(!e||Nn[t+4]&&Nn[t+4].query===e)&&(Nn[t].style.cssText=Nn[t+1],Nn[t].getBBox&&Nn[t].setAttribute("transform",Nn[t+2]||""),Nn[t+3].uncache=1)},Dp=function(){return tt.forEach(function(e){return on(e)&&++e.cacheID&&(e.rec=e())})},$u=function(e,t){var n;for(mn=0;mn<je.length;mn++)n=je[mn],n&&(!t||n._ctx===t)&&(e?n.kill(1):n.revert(!0,!0));ma=!0,t&&Pp(t),t||Xr("revert")},Lp=function(e,t){tt.cache++,(t||!_n)&&tt.forEach(function(n){return on(n)&&n.cacheID++&&(n.rec=0)}),Fn(e)&&(et.history.scrollRestoration=Vu=e)},_n,kr=0,bh,SS=function(){if(bh!==kr){var e=bh=kr;requestAnimationFrame(function(){return e===kr&&Ir(!0)})}},Ip=function(){dt.appendChild(bs),Gu=!pn&&bs.offsetHeight||et.innerHeight,dt.removeChild(bs)},Ah=function(e){return Ca(".gsap-marker-start, .gsap-marker-end, .gsap-marker-scroller-start, .gsap-marker-scroller-end").forEach(function(t){return t.style.display=e?"none":"block"})},Ir=function(e,t){if(Bn=yt.documentElement,dt=yt.body,Hu=[et,yt,Bn,dt],ii&&!e&&!ma){Zt(it,"scrollEnd",Cp);return}Ip(),_n=it.isRefreshing=!0,ma||Dp();var n=Xr("refreshInit");vp&&it.sort(),t||$u(),tt.forEach(function(i){on(i)&&(i.smooth&&(i.target.style.scrollBehavior="auto"),i(0))}),je.slice(0).forEach(function(i){return i.refresh()}),ma=!1,je.forEach(function(i){if(i._subPinOffset&&i.pin){var s=i.vars.horizontal?"offsetWidth":"offsetHeight",a=i.pin[s];i.revert(!0,1),i.adjustPinSpacing(i.pin[s]-a),i.refresh()}}),uu=1,Ah(!0),je.forEach(function(i){var s=xi(i.scroller,i._dir),a=i.vars.end==="max"||i._endClamp&&i.end>s,o=i._startClamp&&i.start>=s;(a||o)&&i.setPositions(o?s-1:i.start,a?Math.max(o?s:i.start+1,s):i.end,!0)}),Ah(!1),uu=0,n.forEach(function(i){return i&&i.render&&i.render(-1)}),tt.forEach(function(i){on(i)&&(i.smooth&&requestAnimationFrame(function(){return i.target.style.scrollBehavior="smooth"}),i.rec&&i(i.rec))}),Lp(Vu,1),Qo.pause(),kr++,_n=2,Bi(2),je.forEach(function(i){return on(i.vars.onRefresh)&&i.vars.onRefresh(i)}),_n=it.isRefreshing=!1,Xr("refresh")},hu=0,Fo=1,Ma,Bi=function(e){if(e===2||!_n&&!ma){it.isUpdating=!0,Ma&&Ma.update(0);var t=je.length,n=sn(),i=n-jl>=50,s=t&&je[0].scroll();if(Fo=hu>s?-1:1,_n||(hu=s),i&&(ii&&!ll&&n-ii>200&&(ii=0,Xr("scrollEnd")),ia=jl,jl=n),Fo<0){for(mn=t;mn-- >0;)je[mn]&&je[mn].update(0,i);Fo=1}else for(mn=0;mn<t;mn++)je[mn]&&je[mn].update(0,i);it.isUpdating=!1}Pa=0},du=[Ap,wp,Xu,Wu,Qn+xa,Qn+_a,Qn+va,Qn+ga,"display","flexShrink","float","zIndex","gridColumnStart","gridColumnEnd","gridRowStart","gridRowEnd","gridArea","justifySelf","alignSelf","placeSelf","order"],Oo=du.concat([Br,zr,"boxSizing","max"+ks,"max"+qu,"position",Qn,zt,zt+va,zt+_a,zt+xa,zt+ga]),yS=function(e,t,n){As(n);var i=e._gsap;if(i.spacerIsNative)As(i.spacerState);else if(e._gsap.swappedIn){var s=t.parentNode;s&&(s.insertBefore(e,t),s.removeChild(t))}e._gsap.swappedIn=!1},ec=function(e,t,n,i){if(!e._gsap.swappedIn){for(var s=du.length,a=t.style,o=e.style,l;s--;)l=du[s],a[l]=n[l];a.position=n.position==="absolute"?"absolute":"relative",n.display==="inline"&&(a.display="inline-block"),o[Xu]=o[Wu]="auto",a.flexBasis=n.flexBasis||"auto",a.overflow="visible",a.boxSizing="border-box",a[Br]=el(e,vn)+Wt,a[zr]=el(e,Xt)+Wt,a[zt]=o[Qn]=o[wp]=o[Ap]="0",As(i),o[Br]=o["max"+ks]=n[Br],o[zr]=o["max"+qu]=n[zr],o[zt]=n[zt],e.parentNode!==t&&(e.parentNode.insertBefore(t,e),t.appendChild(e)),e._gsap.swappedIn=!0}},ES=/([A-Z])/g,As=function(e){if(e){var t=e.t.style,n=e.length,i=0,s,a;for((e.t._gsap||Se.core.getCache(e.t)).uncache=1;i<n;i+=2)a=e[i+1],s=e[i],a?t[s]=a:t[s]&&t.removeProperty(s.replace(ES,"-$1").toLowerCase())}},So=function(e){for(var t=Oo.length,n=e.style,i=[],s=0;s<t;s++)i.push(Oo[s],n[Oo[s]]);return i.t=e,i},TS=function(e,t,n){for(var i=[],s=e.length,a=n?8:0,o;a<s;a+=2)o=e[a],i.push(o,o in t?t[o]:e[a+1]);return i.t=e.t,i},Bo={left:0,top:0},wh=function(e,t,n,i,s,a,o,l,c,u,h,d,f,g){on(e)&&(e=e(l)),Fn(e)&&e.substr(0,3)==="max"&&(e=d+(e.charAt(4)==="="?Uo("0"+e.substr(3),n):0));var _=f?f.time():0,m,p,T;if(f&&f.seek(0),isNaN(e)||(e=+e),aa(e))f&&(e=Se.utils.mapRange(f.scrollTrigger.start,f.scrollTrigger.end,0,d,e)),o&&No(o,n,i,!0);else{on(t)&&(t=t(l));var E=(e||"0").split(" "),x,R,w,b;T=yn(t,l)||dt,x=Di(T)||{},(!x||!x.left&&!x.top)&&ei(T).display==="none"&&(b=T.style.display,T.style.display="block",x=Di(T),b?T.style.display=b:T.style.removeProperty("display")),R=Uo(E[0],x[i.d]),w=Uo(E[1]||"0",n),e=x[i.p]-c[i.p]-u+R+s-w,o&&No(o,w,i,n-w<20||o._isStart&&w>20),n-=n-w}if(g&&(l[g]=e||-.001,e<0&&(e=0)),a){var C=e+n,M=a._isStart;m="scroll"+i.d2,No(a,C,i,M&&C>20||!M&&(h?Math.max(dt[m],Bn[m]):a.parentNode[m])<=C+1),h&&(c=Di(o),h&&(a.style[i.op.p]=c[i.op.p]-i.op.m-a._offset+Wt))}return f&&T&&(m=Di(T),f.seek(d),p=Di(T),f._caScrollDist=m[i.p]-p[i.p],e=e/f._caScrollDist*d),f&&f.seek(_),f?e:Math.round(e)},bS=/(webkit|moz|length|cssText|inset)/i,Rh=function(e,t,n,i){if(e.parentNode!==t){var s=e.style,a,o;if(t===dt){e._stOrig=s.cssText,o=ei(e);for(a in o)!+a&&!bS.test(a)&&o[a]&&typeof s[a]=="string"&&a!=="0"&&(s[a]=o[a]);s.top=n,s.left=i}else s.cssText=e._stOrig;Se.core.getCache(e).uncache=1,t.appendChild(e)}},Up=function(e,t,n){var i=t,s=i;return function(a){var o=Math.round(e());return o!==i&&o!==s&&Math.abs(o-i)>3&&Math.abs(o-s)>3&&(a=o,n&&n()),s=i,i=Math.round(a),i}},yo=function(e,t,n){var i={};i[t.p]="+="+n,Se.set(e,i)},Ch=function(e,t){var n=hr(e,t),i="_scroll"+t.p2,s=function a(o,l,c,u,h){var d=a.tween,f=l.onComplete,g={};c=c||n();var _=Up(n,c,function(){d.kill(),a.tween=0});return h=u&&h||0,u=u||o-c,d&&d.kill(),l[i]=o,l.inherit=!1,l.modifiers=g,g[i]=function(){return _(c+u*d.ratio+h*d.ratio*d.ratio)},l.onUpdate=function(){tt.cache++,a.tween&&Bi()},l.onComplete=function(){a.tween=0,f&&f.call(d)},d=a.tween=Se.to(e,l),d};return e[i]=n,n.wheelHandler=function(){return s.tween&&s.tween.kill()&&(s.tween=0)},Zt(e,"wheel",n.wheelHandler),it.isTouch&&Zt(e,"touchmove",n.wheelHandler),s},it=function(){function r(t,n){hs||r.register(Se)||console.warn("Please gsap.registerPlugin(ScrollTrigger)"),cu(this),this.init(t,n)}var e=r.prototype;return e.init=function(n,i){if(this.progress=this.start=0,this.vars&&this.kill(!0,!0),!ra){this.update=this.refresh=this.kill=pi;return}n=yh(Fn(n)||aa(n)||n.nodeType?{trigger:n}:n,xo);var s=n,a=s.onUpdate,o=s.toggleClass,l=s.id,c=s.onToggle,u=s.onRefresh,h=s.scrub,d=s.trigger,f=s.pin,g=s.pinSpacing,_=s.invalidateOnRefresh,m=s.anticipatePin,p=s.onScrubComplete,T=s.onSnapComplete,E=s.once,x=s.snap,R=s.pinReparent,w=s.pinSpacer,b=s.containerAnimation,C=s.fastScrollEnd,M=s.preventOverlaps,v=n.horizontal||n.containerAnimation&&n.horizontal!==!1?vn:Xt,P=!h&&h!==0,U=yn(n.scroller||et),O=Se.core.getCache(U),G=Gr(U),Y=("pinType"in n?n.pinType:ar(U,"pinType")||G&&"fixed")==="fixed",H=[n.onEnter,n.onLeave,n.onEnterBack,n.onLeaveBack],q=P&&n.toggleActions.split(" "),k="markers"in n?n.markers:xo.markers,ne=G?0:parseFloat(ei(U)["border"+v.p2+ks])||0,D=this,ue=n.onRefreshInit&&function(){return n.onRefreshInit(D)},Ie=mS(U,G,v),$e=_S(U,G),K=0,te=0,_e=0,ie=hr(U,v),Ee,we,He,Ke,Fe,Ce,I,mt,Be,B,Me,rt,Te,A,S,z,Q,J,Z,fe,ae,de,Ge,re,se,Le,Pe,ve,We,Oe,ot,L,ce,$,j,le,he,ze,lt;if(D._startClamp=D._endClamp=!1,D._dir=v,m*=45,D.scroller=U,D.scroll=b?b.time.bind(b):ie,Ke=ie(),D.vars=n,i=i||n.animation,"refreshPriority"in n&&(vp=1,n.refreshPriority===-9999&&(Ma=D)),O.tweenScroll=O.tweenScroll||{top:Ch(U,Xt),left:Ch(U,vn)},D.tweenTo=Ee=O.tweenScroll[v.p],D.scrubDuration=function(pe){ce=aa(pe)&&pe,ce?L?L.duration(pe):L=Se.to(i,{ease:"expo",totalProgress:"+=0",inherit:!1,duration:ce,paused:!0,onComplete:function(){return p&&p(D)}}):(L&&L.progress(1).kill(),L=0)},i&&(i.vars.lazy=!1,i._initted&&!D.isReverted||i.vars.immediateRender!==!1&&n.immediateRender!==!1&&i.duration()&&i.render(0,!0,!0),D.animation=i.pause(),i.scrollTrigger=D,D.scrubDuration(h),Oe=0,l||(l=i.vars.id)),x&&((!wr(x)||x.push)&&(x={snapTo:x}),"scrollBehavior"in dt.style&&Se.set(G?[dt,Bn]:U,{scrollBehavior:"auto"}),tt.forEach(function(pe){return on(pe)&&pe.target===(G?yt.scrollingElement||Bn:U)&&(pe.smooth=!1)}),He=on(x.snapTo)?x.snapTo:x.snapTo==="labels"?vS(i):x.snapTo==="labelsDirectional"?xS(i):x.directional!==!1?function(pe,Ve){return Yu(x.snapTo)(pe,sn()-te<500?0:Ve.direction)}:Se.utils.snap(x.snapTo),$=x.duration||{min:.1,max:2},$=wr($)?pa($.min,$.max):pa($,$),j=Se.delayedCall(x.delay||ce/2||.1,function(){var pe=ie(),Ve=sn()-te<500,Ae=Ee.tween;if((Ve||Math.abs(D.getVelocity())<10)&&!Ae&&!ll&&K!==pe){var ke=(pe-Ce)/A,It=i&&!P?i.totalProgress():ke,Je=Ve?0:(It-ot)/(sn()-ia)*1e3||0,St=Se.utils.clamp(-ke,1-ke,cs(Je/2)*Je/.185),Vt=ke+(x.inertia===!1?0:St),_t,gt,ft=x,Dn=ft.onStart,Et=ft.onInterrupt,cn=ft.onComplete;if(_t=He(Vt,D),aa(_t)||(_t=Vt),gt=Math.max(0,Math.round(Ce+_t*A)),pe<=I&&pe>=Ce&&gt!==pe){if(Ae&&!Ae._initted&&Ae.data<=cs(gt-pe))return;x.inertia===!1&&(St=_t-ke),Ee(gt,{duration:$(cs(Math.max(cs(Vt-It),cs(_t-It))*.185/Je/.05||0)),ease:x.ease||"power3",data:cs(gt-pe),onInterrupt:function(){return j.restart(!0)&&Et&&Et(D)},onComplete:function(){D.update(),K=ie(),i&&!P&&(L?L.resetTo("totalProgress",_t,i._tTime/i._tDur):i.progress(_t)),Oe=ot=i&&!P?i.totalProgress():D.progress,T&&T(D),cn&&cn(D)}},pe,St*A,gt-pe-St*A),Dn&&Dn(D,Ee.tween)}}else D.isActive&&K!==pe&&j.restart(!0)}).pause()),l&&(fu[l]=D),d=D.trigger=yn(d||f!==!0&&f),lt=d&&d._gsap&&d._gsap.stRevert,lt&&(lt=lt(D)),f=f===!0?d:yn(f),Fn(o)&&(o={targets:d,className:o}),f&&(g===!1||g===Qn||(g=!g&&f.parentNode&&f.parentNode.style&&ei(f.parentNode).display==="flex"?!1:zt),D.pin=f,we=Se.core.getCache(f),we.spacer?S=we.pinState:(w&&(w=yn(w),w&&!w.nodeType&&(w=w.current||w.nativeElement),we.spacerIsNative=!!w,w&&(we.spacerState=So(w))),we.spacer=J=w||yt.createElement("div"),J.classList.add("pin-spacer"),l&&J.classList.add("pin-spacer-"+l),we.pinState=S=So(f)),n.force3D!==!1&&Se.set(f,{force3D:!0}),D.spacer=J=we.spacer,We=ei(f),re=We[g+v.os2],fe=Se.getProperty(f),ae=Se.quickSetter(f,v.a,Wt),ec(f,J,We),Q=So(f)),k){rt=wr(k)?yh(k,Eh):Eh,B=Mo("scroller-start",l,U,v,rt,0),Me=Mo("scroller-end",l,U,v,rt,0,B),Z=B["offset"+v.op.d2];var Ct=yn(ar(U,"content")||U);mt=this.markerStart=Mo("start",l,Ct,v,rt,Z,0,b),Be=this.markerEnd=Mo("end",l,Ct,v,rt,Z,0,b),b&&(ze=Se.quickSetter([mt,Be],v.a,Wt)),!Y&&!(Mi.length&&ar(U,"fixedMarkers")===!0)&&(gS(G?dt:U),Se.set([B,Me],{force3D:!0}),Le=Se.quickSetter(B,v.a,Wt),ve=Se.quickSetter(Me,v.a,Wt))}if(b){var ge=b.vars.onUpdate,be=b.vars.onUpdateParams;b.eventCallback("onUpdate",function(){D.update(0,0,1),ge&&ge.apply(b,be||[])})}if(D.previous=function(){return je[je.indexOf(D)-1]},D.next=function(){return je[je.indexOf(D)+1]},D.revert=function(pe,Ve){if(!Ve)return D.kill(!0);var Ae=pe!==!1||!D.enabled,ke=rn;Ae!==D.isReverted&&(Ae&&(le=Math.max(ie(),D.scroll.rec||0),_e=D.progress,he=i&&i.progress()),mt&&[mt,Be,B,Me].forEach(function(It){return It.style.display=Ae?"none":"block"}),Ae&&(rn=D,D.update(Ae)),f&&(!R||!D.isActive)&&(Ae?yS(f,J,S):ec(f,J,ei(f),se)),Ae||D.update(Ae),rn=ke,D.isReverted=Ae)},D.refresh=function(pe,Ve,Ae,ke){if(!((rn||!D.enabled)&&!Ve)){if(f&&pe&&ii){Zt(r,"scrollEnd",Cp);return}!_n&&ue&&ue(D),rn=D,Ee.tween&&!Ae&&(Ee.tween.kill(),Ee.tween=0),L&&L.pause(),_&&i&&(i.revert({kill:!1}).invalidate(),i.getChildren?i.getChildren(!0,!0,!1).forEach(function(Ze){return Ze.vars.immediateRender&&Ze.render(0,!0,!0)}):i.vars.immediateRender&&i.render(0,!0,!0)),D.isReverted||D.revert(!0,!0),D._subPinOffset=!1;var It=Ie(),Je=$e(),St=b?b.duration():xi(U,v),Vt=A<=.01||!A,_t=0,gt=ke||0,ft=wr(Ae)?Ae.end:n.end,Dn=n.endTrigger||d,Et=wr(Ae)?Ae.start:n.start||(n.start===0||!d?0:f?"0 0":"0 100%"),cn=D.pinnedContainer=n.pinnedContainer&&yn(n.pinnedContainer,D),qn=d&&Math.max(0,je.indexOf(D))||0,Gt=qn,y,N,V,W,F,ee,oe,xe,ye,Ue,De,Re,Qe;for(k&&wr(Ae)&&(Re=Se.getProperty(B,v.p),Qe=Se.getProperty(Me,v.p));Gt-- >0;)ee=je[Gt],ee.end||ee.refresh(0,1)||(rn=D),oe=ee.pin,oe&&(oe===d||oe===f||oe===cn)&&!ee.isReverted&&(Ue||(Ue=[]),Ue.unshift(ee),ee.revert(!0,!0)),ee!==je[Gt]&&(qn--,Gt--);for(on(Et)&&(Et=Et(D)),Et=vh(Et,"start",D),Ce=wh(Et,d,It,v,ie(),mt,B,D,Je,ne,Y,St,b,D._startClamp&&"_startClamp")||(f?-.001:0),on(ft)&&(ft=ft(D)),Fn(ft)&&!ft.indexOf("+=")&&(~ft.indexOf(" ")?ft=(Fn(Et)?Et.split(" ")[0]:"")+ft:(_t=Uo(ft.substr(2),It),ft=Fn(Et)?Et:(b?Se.utils.mapRange(0,b.duration(),b.scrollTrigger.start,b.scrollTrigger.end,Ce):Ce)+_t,Dn=d)),ft=vh(ft,"end",D),I=Math.max(Ce,wh(ft||(Dn?"100% 0":St),Dn,It,v,ie()+_t,Be,Me,D,Je,ne,Y,St,b,D._endClamp&&"_endClamp"))||-.001,_t=0,Gt=qn;Gt--;)ee=je[Gt]||{},oe=ee.pin,oe&&ee.start-ee._pinPush<=Ce&&!b&&ee.end>0&&(y=ee.end-(D._startClamp?Math.max(0,ee.start):ee.start),(oe===d&&ee.start-ee._pinPush<Ce||oe===cn)&&isNaN(Et)&&(_t+=y*(1-ee.progress)),oe===f&&(gt+=y));if(Ce+=_t,I+=_t,D._startClamp&&(D._startClamp+=_t),D._endClamp&&!_n&&(D._endClamp=I||-.001,I=Math.min(I,xi(U,v))),A=I-Ce||(Ce-=.01)&&.001,Vt&&(_e=Se.utils.clamp(0,1,Se.utils.normalize(Ce,I,le))),D._pinPush=gt,mt&&_t&&(y={},y[v.a]="+="+_t,cn&&(y[v.p]="-="+ie()),Se.set([mt,Be],y)),f&&!(uu&&D.end>=xi(U,v)))y=ei(f),W=v===Xt,V=ie(),de=parseFloat(fe(v.a))+gt,!St&&I>1&&(De=(G?yt.scrollingElement||Bn:U).style,De={style:De,value:De["overflow"+v.a.toUpperCase()]},G&&ei(dt)["overflow"+v.a.toUpperCase()]!=="scroll"&&(De.style["overflow"+v.a.toUpperCase()]="scroll")),ec(f,J,y),Q=So(f),N=Di(f,!0),xe=Y&&hr(U,W?vn:Xt)(),g?(se=[g+v.os2,A+gt+Wt],se.t=J,Gt=g===zt?el(f,v)+A+gt:0,Gt&&(se.push(v.d,Gt+Wt),J.style.flexBasis!=="auto"&&(J.style.flexBasis=Gt+Wt)),As(se),cn&&je.forEach(function(Ze){Ze.pin===cn&&Ze.vars.pinSpacing!==!1&&(Ze._subPinOffset=!0)}),Y&&ie(le)):(Gt=el(f,v),Gt&&J.style.flexBasis!=="auto"&&(J.style.flexBasis=Gt+Wt)),Y&&(F={top:N.top+(W?V-Ce:xe)+Wt,left:N.left+(W?xe:V-Ce)+Wt,boxSizing:"border-box",position:"fixed"},F[Br]=F["max"+ks]=Math.ceil(N.width)+Wt,F[zr]=F["max"+qu]=Math.ceil(N.height)+Wt,F[Qn]=F[Qn+va]=F[Qn+_a]=F[Qn+xa]=F[Qn+ga]="0",F[zt]=y[zt],F[zt+va]=y[zt+va],F[zt+_a]=y[zt+_a],F[zt+xa]=y[zt+xa],F[zt+ga]=y[zt+ga],z=TS(S,F,R),_n&&ie(0)),i?(ye=i._initted,Kl(1),i.render(i.duration(),!0,!0),Ge=fe(v.a)-de+A+gt,Pe=Math.abs(A-Ge)>1,Y&&Pe&&z.splice(z.length-2,2),i.render(0,!0,!0),ye||i.invalidate(!0),i.parent||i.totalTime(i.totalTime()),Kl(0)):Ge=A,De&&(De.value?De.style["overflow"+v.a.toUpperCase()]=De.value:De.style.removeProperty("overflow-"+v.a));else if(d&&ie()&&!b)for(N=d.parentNode;N&&N!==dt;)N._pinOffset&&(Ce-=N._pinOffset,I-=N._pinOffset),N=N.parentNode;Ue&&Ue.forEach(function(Ze){return Ze.revert(!1,!0)}),D.start=Ce,D.end=I,Ke=Fe=_n?le:ie(),!b&&!_n&&(Ke<le&&ie(le),D.scroll.rec=0),D.revert(!1,!0),te=sn(),j&&(K=-1,j.restart(!0)),rn=0,i&&P&&(i._initted||he)&&i.progress()!==he&&i.progress(he||0,!0).render(i.time(),!0,!0),(Vt||_e!==D.progress||b||_||i&&!i._initted)&&(i&&!P&&(i._initted||_e||i.vars.immediateRender!==!1)&&i.totalProgress(b&&Ce<-.001&&!_e?Se.utils.normalize(Ce,I,0):_e,!0),D.progress=Vt||(Ke-Ce)/A===_e?0:_e),f&&g&&(J._pinOffset=Math.round(D.progress*Ge)),L&&L.invalidate(),isNaN(Re)||(Re-=Se.getProperty(B,v.p),Qe-=Se.getProperty(Me,v.p),yo(B,v,Re),yo(mt,v,Re-(ke||0)),yo(Me,v,Qe),yo(Be,v,Qe-(ke||0))),Vt&&!_n&&D.update(),u&&!_n&&!Te&&(Te=!0,u(D),Te=!1)}},D.getVelocity=function(){return(ie()-Fe)/(sn()-ia)*1e3||0},D.endAnimation=function(){Qs(D.callbackAnimation),i&&(L?L.progress(1):i.paused()?P||Qs(i,D.direction<0,1):Qs(i,i.reversed()))},D.labelToScroll=function(pe){return i&&i.labels&&(Ce||D.refresh()||Ce)+i.labels[pe]/i.duration()*A||0},D.getTrailing=function(pe){var Ve=je.indexOf(D),Ae=D.direction>0?je.slice(0,Ve).reverse():je.slice(Ve+1);return(Fn(pe)?Ae.filter(function(ke){return ke.vars.preventOverlaps===pe}):Ae).filter(function(ke){return D.direction>0?ke.end<=Ce:ke.start>=I})},D.update=function(pe,Ve,Ae){if(!(b&&!Ae&&!pe)){var ke=_n===!0?le:D.scroll(),It=pe?0:(ke-Ce)/A,Je=It<0?0:It>1?1:It||0,St=D.progress,Vt,_t,gt,ft,Dn,Et,cn,qn;if(Ve&&(Fe=Ke,Ke=b?ie():ke,x&&(ot=Oe,Oe=i&&!P?i.totalProgress():Je)),m&&f&&!rn&&!mo&&ii&&(!Je&&Ce<ke+(ke-Fe)/(sn()-ia)*m?Je=1e-4:Je===1&&I>ke+(ke-Fe)/(sn()-ia)*m&&(Je=.9999)),Je!==St&&D.enabled){if(Vt=D.isActive=!!Je&&Je<1,_t=!!St&&St<1,Et=Vt!==_t,Dn=Et||!!Je!=!!St,D.direction=Je>St?1:-1,D.progress=Je,Dn&&!rn&&(gt=Je&&!St?0:Je===1?1:St===1?2:3,P&&(ft=!Et&&q[gt+1]!=="none"&&q[gt+1]||q[gt],qn=i&&(ft==="complete"||ft==="reset"||ft in i))),M&&(Et||qn)&&(qn||h||!i)&&(on(M)?M(D):D.getTrailing(M).forEach(function(V){return V.endAnimation()})),P||(L&&!rn&&!mo?(L._dp._time-L._start!==L._time&&L.render(L._dp._time-L._start),L.resetTo?L.resetTo("totalProgress",Je,i._tTime/i._tDur):(L.vars.totalProgress=Je,L.invalidate().restart())):i&&i.totalProgress(Je,!!(rn&&(te||pe)))),f){if(pe&&g&&(J.style[g+v.os2]=re),!Y)ae(sa(de+Ge*Je));else if(Dn){if(cn=!pe&&Je>St&&I+1>ke&&ke+1>=xi(U,v),R)if(!pe&&(Vt||cn)){var Gt=Di(f,!0),y=ke-Ce;Rh(f,dt,Gt.top+(v===Xt?y:0)+Wt,Gt.left+(v===Xt?0:y)+Wt)}else Rh(f,J);As(Vt||cn?z:Q),Pe&&Je<1&&Vt||ae(de+(Je===1&&!cn?Ge:0))}}x&&!Ee.tween&&!rn&&!mo&&j.restart(!0),o&&(Et||E&&Je&&(Je<1||!Zl))&&Ca(o.targets).forEach(function(V){return V.classList[Vt||E?"add":"remove"](o.className)}),a&&!P&&!pe&&a(D),Dn&&!rn?(P&&(qn&&(ft==="complete"?i.pause().totalProgress(1):ft==="reset"?i.restart(!0).pause():ft==="restart"?i.restart(!0):i[ft]()),a&&a(D)),(Et||!Zl)&&(c&&Et&&Jl(D,c),H[gt]&&Jl(D,H[gt]),E&&(Je===1?D.kill(!1,1):H[gt]=0),Et||(gt=Je===1?1:3,H[gt]&&Jl(D,H[gt]))),C&&!Vt&&Math.abs(D.getVelocity())>(aa(C)?C:2500)&&(Qs(D.callbackAnimation),L?L.progress(1):Qs(i,ft==="reverse"?1:!Je,1))):P&&a&&!rn&&a(D)}if(ve){var N=b?ke/b.duration()*(b._caScrollDist||0):ke;Le(N+(B._isFlipped?1:0)),ve(N)}ze&&ze(-ke/b.duration()*(b._caScrollDist||0))}},D.enable=function(pe,Ve){D.enabled||(D.enabled=!0,Zt(U,"resize",oa),G||Zt(U,"scroll",us),ue&&Zt(r,"refreshInit",ue),pe!==!1&&(D.progress=_e=0,Ke=Fe=K=ie()),Ve!==!1&&D.refresh())},D.getTween=function(pe){return pe&&Ee?Ee.tween:L},D.setPositions=function(pe,Ve,Ae,ke){if(b){var It=b.scrollTrigger,Je=b.duration(),St=It.end-It.start;pe=It.start+St*pe/Je,Ve=It.start+St*Ve/Je}D.refresh(!1,!1,{start:xh(pe,Ae&&!!D._startClamp),end:xh(Ve,Ae&&!!D._endClamp)},ke),D.update()},D.adjustPinSpacing=function(pe){if(se&&pe){var Ve=se.indexOf(v.d)+1;se[Ve]=parseFloat(se[Ve])+pe+Wt,se[1]=parseFloat(se[1])+pe+Wt,As(se)}},D.disable=function(pe,Ve){if(pe!==!1&&D.revert(!0,!0),D.enabled&&(D.enabled=D.isActive=!1,Ve||L&&L.pause(),le=0,we&&(we.uncache=1),ue&&Kt(r,"refreshInit",ue),j&&(j.pause(),Ee.tween&&Ee.tween.kill()&&(Ee.tween=0)),!G)){for(var Ae=je.length;Ae--;)if(je[Ae].scroller===U&&je[Ae]!==D)return;Kt(U,"resize",oa),G||Kt(U,"scroll",us)}},D.kill=function(pe,Ve){D.disable(pe,Ve),L&&!Ve&&L.kill(),l&&delete fu[l];var Ae=je.indexOf(D);Ae>=0&&je.splice(Ae,1),Ae===mn&&Fo>0&&mn--,Ae=0,je.forEach(function(ke){return ke.scroller===D.scroller&&(Ae=1)}),Ae||_n||(D.scroll.rec=0),i&&(i.scrollTrigger=null,pe&&i.revert({kill:!1}),Ve||i.kill()),mt&&[mt,Be,B,Me].forEach(function(ke){return ke.parentNode&&ke.parentNode.removeChild(ke)}),Ma===D&&(Ma=0),f&&(we&&(we.uncache=1),Ae=0,je.forEach(function(ke){return ke.pin===f&&Ae++}),Ae||(we.spacer=0)),n.onKill&&n.onKill(D)},je.push(D),D.enable(!1,!1),lt&&lt(D),i&&i.add&&!A){var Xe=D.update;D.update=function(){D.update=Xe,tt.cache++,Ce||I||D.refresh()},Se.delayedCall(.01,D.update),A=.01,Ce=I=0}else D.refresh();f&&SS()},r.register=function(n){return hs||(Se=n||Ep(),yp()&&window.document&&r.enable(),hs=ra),hs},r.defaults=function(n){if(n)for(var i in n)xo[i]=n[i];return xo},r.disable=function(n,i){ra=0,je.forEach(function(a){return a[i?"kill":"disable"](n)}),Kt(et,"wheel",us),Kt(yt,"scroll",us),clearInterval(po),Kt(yt,"touchcancel",pi),Kt(dt,"touchstart",pi),go(Kt,yt,"pointerdown,touchstart,mousedown",Mh),go(Kt,yt,"pointerup,touchend,mouseup",Sh),Qo.kill(),_o(Kt);for(var s=0;s<tt.length;s+=3)vo(Kt,tt[s],tt[s+1]),vo(Kt,tt[s],tt[s+2])},r.enable=function(){if(et=window,yt=document,Bn=yt.documentElement,dt=yt.body,Se&&(Ca=Se.utils.toArray,pa=Se.utils.clamp,cu=Se.core.context||pi,Kl=Se.core.suppressOverwrites||pi,Vu=et.history.scrollRestoration||"auto",hu=et.pageYOffset||0,Se.core.globals("ScrollTrigger",r),dt)){ra=1,bs=document.createElement("div"),bs.style.height="100vh",bs.style.position="absolute",Ip(),pS(),Ft.register(Se),r.isTouch=Ft.isTouch,Ki=Ft.isTouch&&/(iPad|iPhone|iPod|Mac)/g.test(navigator.userAgent),lu=Ft.isTouch===1,Zt(et,"wheel",us),Hu=[et,yt,Bn,dt],Se.matchMedia?(r.matchMedia=function(c){var u=Se.matchMedia(),h;for(h in c)u.add(h,c[h]);return u},Se.addEventListener("matchMediaInit",function(){Dp(),$u()}),Se.addEventListener("matchMediaRevert",function(){return Pp()}),Se.addEventListener("matchMedia",function(){Ir(0,1),Xr("matchMedia")}),Se.matchMedia().add("(orientation: portrait)",function(){return Ql(),Ql})):console.warn("Requires GSAP 3.11.0 or later"),Ql(),Zt(yt,"scroll",us);var n=dt.hasAttribute("style"),i=dt.style,s=i.borderTopStyle,a=Se.core.Animation.prototype,o,l;for(a.revert||Object.defineProperty(a,"revert",{value:function(){return this.time(-.01,!0)}}),i.borderTopStyle="solid",o=Di(dt),Xt.m=Math.round(o.top+Xt.sc())||0,vn.m=Math.round(o.left+vn.sc())||0,s?i.borderTopStyle=s:i.removeProperty("border-top-style"),n||(dt.setAttribute("style",""),dt.removeAttribute("style")),po=setInterval(Th,250),Se.delayedCall(.5,function(){return mo=0}),Zt(yt,"touchcancel",pi),Zt(dt,"touchstart",pi),go(Zt,yt,"pointerdown,touchstart,mousedown",Mh),go(Zt,yt,"pointerup,touchend,mouseup",Sh),ou=Se.utils.checkPrefix("transform"),Oo.push(ou),hs=sn(),Qo=Se.delayedCall(.2,Ir).pause(),ds=[yt,"visibilitychange",function(){var c=et.innerWidth,u=et.innerHeight;yt.hidden?(_h=c,gh=u):(_h!==c||gh!==u)&&oa()},yt,"DOMContentLoaded",Ir,et,"load",Ir,et,"resize",oa],_o(Zt),je.forEach(function(c){return c.enable(0,1)}),l=0;l<tt.length;l+=3)vo(Kt,tt[l],tt[l+1]),vo(Kt,tt[l],tt[l+2])}},r.config=function(n){"limitCallbacks"in n&&(Zl=!!n.limitCallbacks);var i=n.syncInterval;i&&clearInterval(po)||(po=i)&&setInterval(Th,i),"ignoreMobileResize"in n&&(lu=r.isTouch===1&&n.ignoreMobileResize),"autoRefreshEvents"in n&&(_o(Kt)||_o(Zt,n.autoRefreshEvents||"none"),xp=(n.autoRefreshEvents+"").indexOf("resize")===-1)},r.scrollerProxy=function(n,i){var s=yn(n),a=tt.indexOf(s),o=Gr(s);~a&&tt.splice(a,o?6:2),i&&(o?Mi.unshift(et,i,dt,i,Bn,i):Mi.unshift(s,i))},r.clearMatchMedia=function(n){je.forEach(function(i){return i._ctx&&i._ctx.query===n&&i._ctx.kill(!0,!0)})},r.isInViewport=function(n,i,s){var a=(Fn(n)?yn(n):n).getBoundingClientRect(),o=a[s?Br:zr]*i||0;return s?a.right-o>0&&a.left+o<et.innerWidth:a.bottom-o>0&&a.top+o<et.innerHeight},r.positionInViewport=function(n,i,s){Fn(n)&&(n=yn(n));var a=n.getBoundingClientRect(),o=a[s?Br:zr],l=i==null?o/2:i in tl?tl[i]*o:~i.indexOf("%")?parseFloat(i)*o/100:parseFloat(i)||0;return s?(a.left+l)/et.innerWidth:(a.top+l)/et.innerHeight},r.killAll=function(n){if(je.slice(0).forEach(function(s){return s.vars.id!=="ScrollSmoother"&&s.kill()}),n!==!0){var i=Wr.killAll||[];Wr={},i.forEach(function(s){return s()})}},r}();it.version="3.14.2";it.saveStyles=function(r){return r?Ca(r).forEach(function(e){if(e&&e.style){var t=Nn.indexOf(e);t>=0&&Nn.splice(t,5),Nn.push(e,e.style.cssText,e.getBBox&&e.getAttribute("transform"),Se.core.getCache(e),cu())}}):Nn};it.revert=function(r,e){return $u(!r,e)};it.create=function(r,e){return new it(r,e)};it.refresh=function(r){return r?oa(!0):(hs||it.register())&&Ir(!0)};it.update=function(r){return++tt.cache&&Bi(r===!0?2:0)};it.clearScrollMemory=Lp;it.maxScroll=function(r,e){return xi(r,e?vn:Xt)};it.getScrollFunc=function(r,e){return hr(yn(r),e?vn:Xt)};it.getById=function(r){return fu[r]};it.getAll=function(){return je.filter(function(r){return r.vars.id!=="ScrollSmoother"})};it.isScrolling=function(){return!!ii};it.snapDirectional=Yu;it.addEventListener=function(r,e){var t=Wr[r]||(Wr[r]=[]);~t.indexOf(e)||t.push(e)};it.removeEventListener=function(r,e){var t=Wr[r],n=t&&t.indexOf(e);n>=0&&t.splice(n,1)};it.batch=function(r,e){var t=[],n={},i=e.interval||.016,s=e.batchMax||1e9,a=function(c,u){var h=[],d=[],f=Se.delayedCall(i,function(){u(h,d),h=[],d=[]}).pause();return function(g){h.length||f.restart(!0),h.push(g.trigger),d.push(g),s<=h.length&&f.progress(1)}},o;for(o in e)n[o]=o.substr(0,2)==="on"&&on(e[o])&&o!=="onRefreshInit"?a(o,e[o]):e[o];return on(s)&&(s=s(),Zt(it,"refresh",function(){return s=e.batchMax()})),Ca(r).forEach(function(l){var c={};for(o in n)c[o]=n[o];c.trigger=l,t.push(it.create(c))}),t};var Ph=function(e,t,n,i){return t>i?e(i):t<0&&e(0),n>i?(i-t)/(n-t):n<0?t/(t-n):1},tc=function r(e,t){t===!0?e.style.removeProperty("touch-action"):e.style.touchAction=t===!0?"auto":t?"pan-"+t+(Ft.isTouch?" pinch-zoom":""):"none",e===Bn&&r(dt,t)},Eo={auto:1,scroll:1},AS=function(e){var t=e.event,n=e.target,i=e.axis,s=(t.changedTouches?t.changedTouches[0]:t).target,a=s._gsap||Se.core.getCache(s),o=sn(),l;if(!a._isScrollT||o-a._isScrollT>2e3){for(;s&&s!==dt&&(s.scrollHeight<=s.clientHeight&&s.scrollWidth<=s.clientWidth||!(Eo[(l=ei(s)).overflowY]||Eo[l.overflowX]));)s=s.parentNode;a._isScroll=s&&s!==n&&!Gr(s)&&(Eo[(l=ei(s)).overflowY]||Eo[l.overflowX]),a._isScrollT=o}(a._isScroll||i==="x")&&(t.stopPropagation(),t._gsapAllow=!0)},Np=function(e,t,n,i){return Ft.create({target:e,capture:!0,debounce:!1,lockAxis:!0,type:t,onWheel:i=i&&AS,onPress:i,onDrag:i,onScroll:i,onEnable:function(){return n&&Zt(yt,Ft.eventTypes[0],Lh,!1,!0)},onDisable:function(){return Kt(yt,Ft.eventTypes[0],Lh,!0)}})},wS=/(input|label|select|textarea)/i,Dh,Lh=function(e){var t=wS.test(e.target.tagName);(t||Dh)&&(e._gsapAllow=!0,Dh=t)},RS=function(e){wr(e)||(e={}),e.preventDefault=e.isNormalizer=e.allowClicks=!0,e.type||(e.type="wheel,touch"),e.debounce=!!e.debounce,e.id=e.id||"normalizer";var t=e,n=t.normalizeScrollX,i=t.momentum,s=t.allowNestedScroll,a=t.onRelease,o,l,c=yn(e.target)||Bn,u=Se.core.globals().ScrollSmoother,h=u&&u.get(),d=Ki&&(e.content&&yn(e.content)||h&&e.content!==!1&&!h.smooth()&&h.content()),f=hr(c,Xt),g=hr(c,vn),_=1,m=(Ft.isTouch&&et.visualViewport?et.visualViewport.scale*et.visualViewport.width:et.outerWidth)/et.innerWidth,p=0,T=on(i)?function(){return i(o)}:function(){return i||2.8},E,x,R=Np(c,e.type,!0,s),w=function(){return x=!1},b=pi,C=pi,M=function(){l=xi(c,Xt),C=pa(Ki?1:0,l),n&&(b=pa(0,xi(c,vn))),E=kr},v=function(){d._gsap.y=sa(parseFloat(d._gsap.y)+f.offset)+"px",d.style.transform="matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, "+parseFloat(d._gsap.y)+", 0, 1)",f.offset=f.cacheID=0},P=function(){if(x){requestAnimationFrame(w);var k=sa(o.deltaY/2),ne=C(f.v-k);if(d&&ne!==f.v+f.offset){f.offset=ne-f.v;var D=sa((parseFloat(d&&d._gsap.y)||0)-f.offset);d.style.transform="matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, "+D+", 0, 1)",d._gsap.y=D+"px",f.cacheID=tt.cache,Bi()}return!0}f.offset&&v(),x=!0},U,O,G,Y,H=function(){M(),U.isActive()&&U.vars.scrollY>l&&(f()>l?U.progress(1)&&f(l):U.resetTo("scrollY",l))};return d&&Se.set(d,{y:"+=0"}),e.ignoreCheck=function(q){return Ki&&q.type==="touchmove"&&P()||_>1.05&&q.type!=="touchstart"||o.isGesturing||q.touches&&q.touches.length>1},e.onPress=function(){x=!1;var q=_;_=sa((et.visualViewport&&et.visualViewport.scale||1)/m),U.pause(),q!==_&&tc(c,_>1.01?!0:n?!1:"x"),O=g(),G=f(),M(),E=kr},e.onRelease=e.onGestureStart=function(q,k){if(f.offset&&v(),!k)Y.restart(!0);else{tt.cache++;var ne=T(),D,ue;n&&(D=g(),ue=D+ne*.05*-q.velocityX/.227,ne*=Ph(g,D,ue,xi(c,vn)),U.vars.scrollX=b(ue)),D=f(),ue=D+ne*.05*-q.velocityY/.227,ne*=Ph(f,D,ue,xi(c,Xt)),U.vars.scrollY=C(ue),U.invalidate().duration(ne).play(.01),(Ki&&U.vars.scrollY>=l||D>=l-1)&&Se.to({},{onUpdate:H,duration:ne})}a&&a(q)},e.onWheel=function(){U._ts&&U.pause(),sn()-p>1e3&&(E=0,p=sn())},e.onChange=function(q,k,ne,D,ue){if(kr!==E&&M(),k&&n&&g(b(D[2]===k?O+(q.startX-q.x):g()+k-D[1])),ne){f.offset&&v();var Ie=ue[2]===ne,$e=Ie?G+q.startY-q.y:f()+ne-ue[1],K=C($e);Ie&&$e!==K&&(G+=K-$e),f(K)}(ne||k)&&Bi()},e.onEnable=function(){tc(c,n?!1:"x"),it.addEventListener("refresh",H),Zt(et,"resize",H),f.smooth&&(f.target.style.scrollBehavior="auto",f.smooth=g.smooth=!1),R.enable()},e.onDisable=function(){tc(c,!0),Kt(et,"resize",H),it.removeEventListener("refresh",H),R.kill()},e.lockAxis=e.lockAxis!==!1,o=new Ft(e),o.iOS=Ki,Ki&&!f()&&f(1),Ki&&Se.ticker.add(pi),Y=o._dc,U=Se.to(o,{ease:"power4",paused:!0,inherit:!1,scrollX:n?"+=0.1":"+=0",scrollY:"+=0.1",modifiers:{scrollY:Up(f,f(),function(){return U.pause()})},onUpdate:Bi,onComplete:Y.vars.onComplete}),o};it.sort=function(r){if(on(r))return je.sort(r);var e=et.pageYOffset||0;return it.getAll().forEach(function(t){return t._sortY=t.trigger?e+t.trigger.getBoundingClientRect().top:t.start+et.innerHeight}),je.sort(r||function(t,n){return(t.vars.refreshPriority||0)*-1e6+(t.vars.containerAnimation?1e6:t._sortY)-((n.vars.containerAnimation?1e6:n._sortY)+(n.vars.refreshPriority||0)*-1e6)})};it.observe=function(r){return new Ft(r)};it.normalizeScroll=function(r){if(typeof r>"u")return pn;if(r===!0&&pn)return pn.enable();if(r===!1){pn&&pn.kill(),pn=r;return}var e=r instanceof Ft?r:RS(r);return pn&&pn.target===e.target&&pn.kill(),Gr(e.target)&&(pn=e),e};it.core={_getVelocityProp:au,_inputObserver:Np,_scrollers:tt,_proxies:Mi,bridge:{ss:function(){ii||Xr("scrollStart"),ii=sn()},ref:function(){return rn}}};Ep()&&Se.registerPlugin(it);Ht.registerPlugin(it);function CS(){const r=document.getElementById("navbar");if(!r)return;it.create({start:"top -80px",onEnter:()=>r.classList.add("scrolled"),onLeaveBack:()=>r.classList.remove("scrolled")});const e=document.getElementById("burger"),t=document.getElementById("mobile-menu"),n=document.getElementById("mobile-close");e&&t&&(e.addEventListener("click",()=>t.classList.add("open")),n==null||n.addEventListener("click",()=>t.classList.remove("open")),t.querySelectorAll("a").forEach(i=>i.addEventListener("click",()=>t.classList.remove("open"))))}function PS(){Ht.timeline({delay:.3}).from(".hero-badge",{opacity:0,y:20,duration:.6,ease:"power2.out"}).from(".hero-title",{opacity:0,y:35,duration:.7,ease:"power2.out"},"-=0.3").from(".hero-sub",{opacity:0,y:25,duration:.6,ease:"power2.out"},"-=0.4").from(".hero-ctas",{opacity:0,y:20,duration:.5,ease:"power2.out"},"-=0.3").from(".trust-bar",{opacity:0,y:15,duration:.5,ease:"power2.out"},"-=0.2").from(".scroll-hint",{opacity:0,duration:.5},"-=0.1")}function DS(){Ht.from(".stat-item",{opacity:0,y:30,duration:.6,stagger:.12,ease:"power2.out",scrollTrigger:{trigger:"#stats",start:"top 80%"}})}function LS(){Ht.from(".feature-card",{opacity:0,y:40,duration:.65,stagger:.08,ease:"power2.out",scrollTrigger:{trigger:".features-grid",start:"top 80%"}})}function IS(){Ht.from("#ia .section-title",{opacity:0,y:30,duration:.7,ease:"power2.out",scrollTrigger:{trigger:"#ia",start:"top 80%"}}),Ht.from(".phone-mockup-wrap",{opacity:0,x:-60,duration:.9,ease:"power2.out",scrollTrigger:{trigger:".ia-inner",start:"top 75%"}}),Ht.from(".ia-text-col",{opacity:0,x:60,duration:.9,ease:"power2.out",scrollTrigger:{trigger:".ia-inner",start:"top 75%"}}),Ht.from(".ia-step",{opacity:0,y:25,duration:.6,stagger:.15,ease:"power2.out",scrollTrigger:{trigger:".ia-steps",start:"top 80%"}})}function US(){document.querySelectorAll(".screen-card").forEach((e,t)=>{const n=t===0?-50:t===2?50:0;Ht.from(e,{opacity:0,x:n,y:n===0?40:20,duration:.8,ease:"power2.out",scrollTrigger:{trigger:".screenshots-grid",start:"top 78%"},delay:t*.12})})}function NS(){Ht.from(".testi-card",{opacity:0,y:35,scale:.97,duration:.65,stagger:.12,ease:"power2.out",scrollTrigger:{trigger:".testimonials-grid",start:"top 80%"}})}function FS(){Ht.from(".pricing-card",{opacity:0,y:40,scale:.97,duration:.8,ease:"back.out(1.2)",scrollTrigger:{trigger:"#pricing",start:"top 78%"}})}function OS(){Ht.from(".faq-item",{opacity:0,y:20,stagger:.08,duration:.5,ease:"power2.out",scrollTrigger:{trigger:".faq-list",start:"top 82%"}}),document.querySelectorAll(".faq-question").forEach(r=>{r.addEventListener("click",()=>{const e=r.closest(".faq-item"),t=e.querySelector(".faq-answer"),n=e.classList.contains("open");if(document.querySelectorAll(".faq-item.open").forEach(i=>{if(i!==e){const s=i.querySelector(".faq-answer");Ht.to(s,{height:0,duration:.35,ease:"power2.inOut"}),i.classList.remove("open")}}),n)Ht.to(t,{height:0,duration:.35,ease:"power2.inOut"}),e.classList.remove("open");else{e.classList.add("open");const s=t.querySelector(".faq-answer-inner").offsetHeight;Ht.fromTo(t,{height:0},{height:s,duration:.4,ease:"power2.out"})}})})}function BS(){Ht.from("#cta-final h2",{opacity:0,y:40,duration:.8,ease:"power2.out",scrollTrigger:{trigger:"#cta-final",start:"top 80%"}}),Ht.from("#cta-final p",{opacity:0,y:25,duration:.7,ease:"power2.out",delay:.15,scrollTrigger:{trigger:"#cta-final",start:"top 80%"}}),Ht.from(".cta-final-btn",{opacity:0,y:20,scale:.95,duration:.6,ease:"back.out(1.5)",delay:.3,scrollTrigger:{trigger:"#cta-final",start:"top 80%"}})}function zS(){document.querySelectorAll(".section-title").forEach(r=>{Ht.from(r,{opacity:0,y:30,duration:.7,ease:"power2.out",scrollTrigger:{trigger:r,start:"top 85%"}})})}function kS(){CS(),PS(),DS(),LS(),IS(),US(),NS(),FS(),OS(),BS(),zS()}function HS(r){const e=parseFloat(r.dataset.target),t=r.dataset.suffix||"",n=r.dataset.prefix||"",i=r.dataset.decimals?parseInt(r.dataset.decimals):0,s=1800,a=performance.now();function o(c){return 1-Math.pow(1-c,4)}function l(c){const u=c-a,h=Math.min(u/s,1),f=o(h)*e;r.textContent=n+f.toFixed(i)+t,h<1?requestAnimationFrame(l):r.textContent=n+e.toFixed(i)+t}requestAnimationFrame(l)}function VS(){const r=document.querySelectorAll("[data-counter]");if(!r.length)return;const e=new IntersectionObserver(t=>{t.forEach(n=>{n.isIntersecting&&!n.target._counted&&(n.target._counted=!0,HS(n.target),e.unobserve(n.target))})},{threshold:.5});r.forEach(t=>e.observe(t))}document.querySelector("#app").innerHTML=`

  <!-- ── Fond mesh ambiant ──────────────────────────────── -->
  <div class="mesh-bg"></div>

  <!-- ═══════════════════════════════════════════════════════
       NAVBAR
  ════════════════════════════════════════════════════════ -->
  <nav id="navbar">
    <a href="#" class="nav-logo">
      <span class="nav-spark">🔥</span>CraftOS
    </a>
    <div class="nav-links">
      <a href="#features"     class="nav-link">Fonctionnalités</a>
      <a href="#testimonials" class="nav-link">Témoignages</a>
      <a href="#pricing"      class="nav-link">Tarifs</a>
      <a href="#faq"          class="nav-link">FAQ</a>
      <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary" style="padding:0.6rem 1.5rem;font-size:0.9rem;">
        Connexion →
      </a>
    </div>
    <button id="burger" class="burger" aria-label="Menu">
      <span></span><span></span><span></span>
    </button>
  </nav>

  <!-- Menu mobile overlay -->
  <div id="mobile-menu" class="nav-mobile-overlay">
    <button id="mobile-close" class="mobile-close" aria-label="Fermer">✕</button>
    <a href="#features"     >Fonctionnalités</a>
    <a href="#testimonials" >Témoignages</a>
    <a href="#pricing"      >Tarifs</a>
    <a href="#faq"          >FAQ</a>
    <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary">Commencer gratuitement</a>
  </div>

  <!-- ═══════════════════════════════════════════════════════
       HERO
  ════════════════════════════════════════════════════════ -->
  <section id="hero">
    <canvas id="hero-canvas"></canvas>

    <div class="hero-content">
      <div class="hero-badge">
        <span class="badge"><span class="dot"></span>500+ artisans actifs</span>
        <span class="badge badge-indigo" style="margin-left:0.75rem;">Gemini 2.0 Flash</span>
      </div>

      <h1 class="hero-title">
        Le SaaS BTP<br>
        <em>Ultime &amp; Gratuit</em>
      </h1>

      <p class="hero-sub">
        Design Apple. Automatisation Tesla.<br>
        Gestion financière parfaite pour les artisans modernes,<br>
        100&nbsp;% cloud et assistée par I.A.
      </p>

      <div class="hero-ctas">
        <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary" style="font-size:1.1rem;padding:1rem 2.5rem;">
          ⚡ Commencer gratuitement
        </a>
        <a href="#features" class="btn-secondary">
          Découvrir les fonctionnalités
        </a>
      </div>

      <div class="trust-bar">
        <div class="trust-item"><span>🏆</span> 100&nbsp;% Gratuit</div>
        <div class="trust-item"><span>🔒</span> Données sécurisées</div>
        <div class="trust-item"><span>⚡</span> Devis en 30&nbsp;s</div>
        <div class="trust-item"><span>🇫🇷</span> Conforme France</div>
      </div>
    </div>

    <div class="scroll-hint">
      <svg viewBox="0 0 24 24"><path d="M12 5v14m0 0-6-6m6 6 6-6"/></svg>
      Scroll
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       STATS BAR
  ════════════════════════════════════════════════════════ -->
  <section id="stats">
    <div class="stats-grid">
      <div class="stat-item">
        <div class="stat-number" data-counter data-target="500" data-suffix="+">0+</div>
        <div class="stat-label">Artisans actifs</div>
      </div>
      <div class="stat-item">
        <div class="stat-number" data-counter data-target="30" data-suffix="s">0s</div>
        <div class="stat-label">Pour créer un devis</div>
      </div>
      <div class="stat-item">
        <div class="stat-number" data-counter data-target="4.9" data-decimals="1" data-suffix="★">0★</div>
        <div class="stat-label">Note utilisateurs</div>
      </div>
      <div class="stat-item">
        <div class="stat-number">0€</div>
        <div class="stat-label">Zéro abonnement</div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       FEATURES
  ════════════════════════════════════════════════════════ -->
  <section id="features" class="section">
    <div class="section-title">
      <h2>Passez à la vitesse supérieure</h2>
      <p>Chaque fonctionnalité a été pensée pour l'artisan du quotidien.</p>
      <span class="section-divider"></span>
    </div>

    <div class="features-grid">

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🤖</div>
        <h3>CRM Magique &amp; OCR</h3>
        <p>Extraction des factures fournisseurs par I.A. et auto-complétion SIRET via Pappers et la Base Adresse Nationale. Zéro saisie manuelle.</p>
        <span class="feature-tag">→ Gain de temps</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🎙️</div>
        <h3>Aitise ton Devis</h3>
        <p>Dictez votre chantier à la voix, Gemini 2.0 génère le devis structuré et chiffre les lignes matériaux / main-d'œuvre avec votre propre catalogue.</p>
        <span class="feature-tag">→ Powered by Gemini 2.0</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">📊</div>
        <h3>Cockpit Financier</h3>
        <p>Progress Billing ultime. Suivez votre CA, votre marge nette et optimisez vos cotisations URSSAF avec des curseurs intelligents.</p>
        <span class="feature-tag">→ Rentabilité maximale</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">⚡</div>
        <h3>Encaissement Flash</h3>
        <p>Vos factures PDF premium incluent automatiquement un QR Code SEPA (EPC). Vos clients vous paient en un simple scan bancaire.</p>
        <span class="feature-tag">→ Paiement instantané</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🎨</div>
        <h3>PDF Studio</h3>
        <p>Choisissez parmi plusieurs thèmes premium (Classique, Moderne, Épuré) et prévisualisez votre document en temps réel avant envoi.</p>
        <span class="feature-tag">→ Documents professionnels</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🔄</div>
        <h3>Factures Récurrentes</h3>
        <p>Automatisez vos abonnements et contrats de maintenance. Générez et envoyez automatiquement chaque mois sans lever le petit doigt.</p>
        <span class="feature-tag">→ Zéro oubli</span>
      </div>

    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       IA SHOWCASE
  ════════════════════════════════════════════════════════ -->
  <section id="ia" class="section">
    <div class="section-title reveal">
      <h2>L'I.A. qui <em class="text-gradient-fire">parle chantier</em></h2>
      <p>Dictez, l'I.A. structure. Validez, c'est envoyé.</p>
      <span class="section-divider"></span>
    </div>

    <div class="ia-inner">
      <div class="phone-mockup-wrap">
        <div class="phone-mockup">
          <div class="phone-notch"></div>
          <div class="phone-screen">
            <img
              src="https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=560&q=80&auto=format"
              alt="Interface devis vocal CraftOS"
              loading="lazy"
            />
          </div>
          <div class="phone-glow"></div>
          <div class="live-badge"><span style="width:6px;height:6px;border-radius:50%;background:#fff;animation:pulse-dot 1.5s infinite"></span> LIVE</div>
        </div>
      </div>

      <div class="ia-text-col">
        <div class="badge" style="margin-bottom:1.5rem;">🎙️ Devis vocal en 3 étapes</div>
        <h3 style="font-size:clamp(1.5rem,3vw,2.25rem);font-weight:800;margin-bottom:1rem;line-height:1.2;">
          Parlez. L'I.A.<br><span class="text-gradient-fire">fait le reste.</span>
        </h3>
        <p style="color:var(--text-3);margin-bottom:2rem;line-height:1.75;">
          Plus besoin de taper ligne par ligne. Décrivez votre chantier à voix haute,
          CraftOS génère un devis complet et chiffré en moins de 30 secondes.
        </p>

        <div class="ia-steps">
          <div class="ia-step">
            <div class="step-num">1</div>
            <div>
              <h4>Décrivez votre chantier</h4>
              <p>« Pose de 30m² de carrelage salle de bain, fourniture et main d'œuvre »</p>
            </div>
          </div>
          <div class="ia-step">
            <div class="step-num">2</div>
            <div>
              <h4>L'I.A. structure et chiffre</h4>
              <p>Gemini 2.0 génère les lignes matériaux/MO avec vos tarifs et votre catalogue.</p>
            </div>
          </div>
          <div class="ia-step">
            <div class="step-num">3</div>
            <div>
              <h4>Validez et envoyez</h4>
              <p>Ajustez si besoin, signez électroniquement et envoyez le PDF professionnel.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       SCREENSHOTS
  ════════════════════════════════════════════════════════ -->
  <section id="screenshots" class="section">
    <div class="section-title reveal">
      <h2>Une interface <span class="text-gradient-fire">taillée pour l'artisan</span></h2>
      <p>Pensée pour aller vite, pas pour les comptables.</p>
      <span class="section-divider"></span>
    </div>

    <div class="screenshots-grid">
      <div class="screen-card">
        <div class="screen-header">
          <div class="screen-dot" style="background:#ef4444;"></div>
          <div class="screen-dot" style="background:#f59e0b;"></div>
          <div class="screen-dot" style="background:#10b981;"></div>
        </div>
        <img
          class="screen-img"
          src="https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&q=75&auto=format"
          alt="Vue devis CraftOS"
          loading="lazy"
        />
        <div class="screen-label">📋 Devis &amp; Factures</div>
      </div>

      <div class="screen-card">
        <div class="screen-header">
          <div class="screen-dot" style="background:#ef4444;"></div>
          <div class="screen-dot" style="background:#f59e0b;"></div>
          <div class="screen-dot" style="background:#10b981;"></div>
        </div>
        <img
          class="screen-img"
          src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&q=75&auto=format"
          alt="Cockpit financier CraftOS"
          loading="lazy"
        />
        <div class="screen-label">📊 Cockpit Financier</div>
      </div>

      <div class="screen-card">
        <div class="screen-header">
          <div class="screen-dot" style="background:#ef4444;"></div>
          <div class="screen-dot" style="background:#f59e0b;"></div>
          <div class="screen-dot" style="background:#10b981;"></div>
        </div>
        <img
          class="screen-img"
          src="https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&q=75&auto=format"
          alt="Chantier BTP CraftOS"
          loading="lazy"
        />
        <div class="screen-label">🏗️ Suivi Chantiers</div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       TÉMOIGNAGES
  ════════════════════════════════════════════════════════ -->
  <section id="testimonials" class="section">
    <div class="section-title reveal">
      <h2>Ils ont adopté CraftOS</h2>
      <p>Des artisans qui gagnent 2h par jour sur leur admin.</p>
      <span class="section-divider"></span>
    </div>

    <div class="testimonials-grid">

      <div class="testi-card glass">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-quote">
          « Avant je perdais des heures sur mes devis. Maintenant je dicte le chantier
          en 2 minutes et le PDF part automatiquement. Mes clients sont bluffés. »
        </p>
        <div class="testi-author">
          <img
            class="testi-avatar"
            src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=96&q=80&auto=format&fit=crop&crop=face"
            alt="Julien M."
            loading="lazy"
          />
          <div>
            <div class="testi-name">Julien M.</div>
            <div class="testi-role">Maçon — Grenoble</div>
          </div>
        </div>
      </div>

      <div class="testi-card glass">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-quote">
          « Le QR Code SEPA sur les factures, c'est magique. Mes clients scannent
          et je suis payé le jour même. Mon délai moyen est passé de 45 à 3 jours. »
        </p>
        <div class="testi-author">
          <img
            class="testi-avatar"
            src="https://images.unsplash.com/photo-1560250097-0b93528c311a?w=96&q=80&auto=format&fit=crop&crop=face"
            alt="Karim B."
            loading="lazy"
          />
          <div>
            <div class="testi-name">Karim B.</div>
            <div class="testi-role">Électricien — Lyon</div>
          </div>
        </div>
      </div>

      <div class="testi-card glass">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-quote">
          « Le cockpit URSSAF m'évite les mauvaises surprises. Je vois en temps réel
          ce que je dois provisionner. C'est le seul outil dont j'avais besoin. »
        </p>
        <div class="testi-author">
          <img
            class="testi-avatar"
            src="https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=96&q=80&auto=format&fit=crop&crop=face"
            alt="Sophie L."
            loading="lazy"
          />
          <div>
            <div class="testi-name">Sophie L.</div>
            <div class="testi-role">Plombière — Bordeaux</div>
          </div>
        </div>
      </div>

    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       PRICING
  ════════════════════════════════════════════════════════ -->
  <section id="pricing" class="section" style="text-align:center;">
    <div class="section-title reveal">
      <h2>Zéro coût caché,<br><span class="text-gradient-fire">Zéro abonnement</span></h2>
      <p>Toutes les fonctionnalités pour tous les artisans. Gratuit pour toujours.</p>
      <span class="section-divider"></span>
    </div>

    <div class="pricing-card glass-fire">
      <span class="pricing-label">🔥 Offre unique</span>
      <div>
        <span class="pricing-price">0€</span><span class="pricing-period">/mois</span>
      </div>
      <p class="pricing-tagline">Accès complet sans carte bancaire, sans engagement, pour toujours.</p>

      <ul class="pricing-features">
        <li>Devis et factures illimités</li>
        <li>CRM Magique &amp; OCR Fournisseurs</li>
        <li>Aitise ton Devis (Gemini 2.0 Flash)</li>
        <li>Cockpit Financier &amp; Progress Billing</li>
        <li>QR Code SEPA sur chaque facture</li>
        <li>PDF Studio — 3 thèmes premium</li>
        <li>Factures récurrentes automatiques</li>
        <li>Rappels URSSAF, CFE, TVA</li>
        <li>Signature électronique</li>
        <li>Support 24/7 par I.A.</li>
      </ul>

      <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary btn-full" style="font-size:1.1rem;padding:1.125rem;">
        ⚡ Créer mon compte gratuitement
      </a>
      <p class="pricing-security">🔒 Données chiffrées · Hébergé en Europe · RGPD conforme</p>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       FAQ
  ════════════════════════════════════════════════════════ -->
  <section id="faq" class="section">
    <div class="section-title reveal">
      <h2>Questions fréquentes</h2>
      <span class="section-divider"></span>
    </div>

    <div class="faq-list">

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          CraftOS est-il vraiment gratuit ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Oui, 100&nbsp;% gratuit. Pas de plan freemium, pas de limite artificielle.
          CraftOS est financé par des services optionnels futurs. Toutes les fonctionnalités
          actuelles resteront gratuites à vie pour les utilisateurs inscrits avant le lancement payant.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          Mes données sont-elles sécurisées ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Vos données sont chiffrées en transit (TLS) et au repos, hébergées en Europe
          (Supabase / AWS eu-west). Chaque compte est isolé via Row-Level Security PostgreSQL.
          Nous sommes conformes RGPD et ne revendons jamais vos données.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          La numérotation de mes devis et factures est-elle légale ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Absolument. CraftOS génère des numéros séquentiels sans saut via des transactions
          atomiques en base de données, conformément aux obligations françaises (article L441-9 CGI).
          Les documents validés sont immuables et horodatés.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          Fonctionne-t-il pour les micro-entrepreneurs ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Parfaitement. CraftOS gère la franchise en base de TVA (mention légale automatique),
          le calcul des cotisations URSSAF avec les taux 2026, et le suivi du seuil de chiffre
          d'affaires. Conçu spécifiquement pour les artisans en micro-entreprise.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          Puis-je importer mes données existantes ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Oui. CraftOS dispose d'un module d'import CSV pour vos clients et catalogue de produits.
          Notre équipe peut vous accompagner gratuitement pour migrer depuis Excel,
          Henrri, Indy ou tout autre logiciel.
        </div></div>
      </div>

    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       CTA FINALE
  ════════════════════════════════════════════════════════ -->
  <section id="cta-final">
    <div class="cta-bg"></div>
    <div class="cta-final-inner">
      <div class="badge" style="margin-bottom:1.5rem;">⚡ Rejoignez 500+ artisans</div>
      <h2>Prêt à<br><span class="text-gradient-fire">reprendre le contrôle ?</span></h2>
      <p>Créez votre compte en 30 secondes. Aucune carte bancaire requise.</p>
      <a href="https://app-craftos.vercel.app/signup#/login" class="cta-final-btn">
        <span>🔥</span> Commencer gratuitement
      </a>
      <p class="cta-counter">
        <strong id="live-counter">12</strong> artisans se sont inscrits cette semaine
      </p>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       FOOTER
  ════════════════════════════════════════════════════════ -->
  <footer id="footer">
    <div class="footer-grid">
      <div class="footer-brand">
        <a href="#" class="nav-logo"><span class="nav-spark">🔥</span>CraftOS</a>
        <p>Le SaaS de gestion BTP pensé pour les artisans français. Devis, factures, cockpit financier — tout en un, gratuit.</p>
        <div class="social-links">
          <a href="#" class="social-link" aria-label="LinkedIn">
            <svg viewBox="0 0 24 24"><path d="M16 8a6 6 0 016 6v7h-4v-7a2 2 0 00-2-2 2 2 0 00-2 2v7h-4v-7a6 6 0 016-6zM2 9h4v12H2zm2-3a2 2 0 100-4 2 2 0 000 4z"/></svg>
          </a>
          <a href="#" class="social-link" aria-label="Twitter / X">
            <svg viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231 5.45-6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
          </a>
        </div>
      </div>

      <div class="footer-col">
        <h4>Produit</h4>
        <ul class="footer-links">
          <li><a href="#features">Fonctionnalités</a></li>
          <li><a href="#pricing">Tarifs</a></li>
          <li><a href="#testimonials">Témoignages</a></li>
          <li><a href="#faq">FAQ</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h4>Légal</h4>
        <ul class="footer-links">
          <li><a href="#">Mentions légales</a></li>
          <li><a href="#">CGU</a></li>
          <li><a href="#">Politique de confidentialité</a></li>
          <li><a href="#">Cookies</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h4>Contact</h4>
        <ul class="footer-links">
          <li><a href="mailto:contact@craftos.fr">contact@craftos.fr</a></li>
          <li><a href="#">Centre d'aide</a></li>
          <li><a href="#">Signaler un bug</a></li>
        </ul>
      </div>
    </div>

    <div class="footer-bottom">
      <p>© 2026 CraftOS. Fait avec <span class="footer-heart">♥</span> en France.</p>
      <p>Conformité RGPD · Données hébergées en Europe</p>
    </div>
  </footer>
`;window.addEventListener("DOMContentLoaded",()=>{Xx(),kS(),VS();const r=document.getElementById("live-counter");if(r){let e=12;setInterval(()=>{Math.random()<.3&&(e+=Math.floor(Math.random()*2)+1,r.textContent=e)},8e3)}});
