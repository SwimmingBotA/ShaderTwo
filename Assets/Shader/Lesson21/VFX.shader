// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/VFX"
{
    Properties
    {
      [Header(Texture)]
        _MainTex ("MainTex A:AO",2D)="white"{}
        _BumpTex ("BumpTex",2D)="bump"{}
        _SpeTex ("SpeTex A:SpePow",2D)="gray"{}
        _CubeMap ("CubeMap",Cube)="_Skybox"{}
     [Header(Glass)]
        _CubeMapLevel("CubeMapLevel",Range(1.0,10.0))=1.0
        _SpePow("SpePow",Range(1.0,30.0))=8.0
        _EnvIntensity("EnvIntensity",Range(0.0,20.0))=1.0
        _EmitIntensity("EmitIntensity",Range(0.0,10.0))=1.0
        _FresnelPow("FresnelPow",Range(1.0,30.0))=1.0
     [Header(Color)]
        _TopColor("TopColor",Color)=(1.0,1.0,1.0,1.0)
        _SideColor("SideColor",Color)=(1.0,1.0,1.0,1.0)
        _DownColor("DownColor",Color)=(1.0,1.0,1.0,1.0)
     [Header(Effect)]
        _Effect01("Effect01",2D)="white"{}
        _Effect02("Effect02",2D)="white"{}
        _EffParams("X:T Y:V Z:MaskInt W:SpreadInt",Vector)=(0.0,0.0,0.0,0.0)
        [HDR] _EffectColor("EffectColor",Color)=(1.0,1.0,1.0,1.0)

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"     
        }
        Pass
        {
           Tags
           { 
           "LightMode"="ForwardBase"
           }
           Blend One OneMinusSrcAlpha
           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #pragma mulit_compile_fwdbase_fullshadow
           #include "UnityCG.cginc"
           #include "Lighting.cginc"
           #include "AutoLight.cginc"
           #include "../Cginc/EnvColor.cginc"

           sampler2D _MainTex;
           float4 _MainTex_ST;
           sampler2D _BumpTex;
           sampler2D _SpeTex;
           samplerCUBE _CubeMap;

           half _SpePow;
           half _FresnelPow;
           half _CubeMapLevel;
           half _EnvIntensity;

           half4 _TopColor;
           half4 _SideColor;
           half4 _DownColor;
           half4 _EffectColor;

           sampler2D _Effect01;
           sampler2D _Effect02;
           float4 _EffParams;

           struct a2v
           {
             float4 vertex:POSITION;
             float3 normal:NORMAL;
             float4 tangent:TANGENT;
             float3 color:COLOR;
             float2 uv:TEXCOORD0;
             float2 uv1:TEXCOORD1;
           };

           struct v2f
           {
             float4 pos:SV_POSITION;
             float3 worldPos:TEXCOORD0;
             float3 worldNormal:TEXCOORD1;
             float3 worldTangent:TEXCOORD2;
             float3 worldBiTangent:TEXCOORD3;
             float4 effectMask:TEXCOORD4;
             float2 uv:TEXCOORD5;
             float2 uv1:TEXCOORD6;
             LIGHTING_COORDS(7,8)
           };

           float4 Effecting(float noise,float mask,float3 normal,inout float3 vertex)
           {
                float baseMask = abs(frac(vertex.y*_EffParams.x-_Time.x*_EffParams.y)-0.5)*2.0;
                //float baseMask = abs(frac(vertex.y*_EffParams.x)-0.5)*2.0;
                baseMask = min(1.0,baseMask*2.0);
                baseMask +=(noise-0.5)*_EffParams.z;
                float4 effectMask = float4(0.0,0.0,0.0,0.0);
                effectMask.x = smoothstep(0.0,0.9,baseMask);
                effectMask.y = smoothstep(0.2,0.7,baseMask);
                effectMask.z = smoothstep(0.4,0.6,baseMask);
                effectMask.w = mask;

                vertex.xz +=normal.xz*(1-effectMask.x)*_EffParams.w*mask;
                return effectMask;
                //return baseMask;
           }


           v2f vert(a2v v)
           {
             v2f o;
             float noise = tex2Dlod(_Effect02,float4(v.uv1,0.0,0.0)).r;
             o.effectMask = Effecting(noise,v.color.r,v.normal,v.vertex.xyz);
             o.pos = UnityObjectToClipPos(v.vertex);
             o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
             o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
             o.worldTangent = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
             o.worldBiTangent = normalize(cross(o.worldNormal,o.worldTangent)*v.tangent.w);
             o.uv = TRANSFORM_TEX(v.uv,_MainTex);
             o.uv1 =v.uv1;
             TRANSFER_VERTEX_TO_FRAGMENT(o);
             return o;
           }

          float4 frag(v2f i):SV_Target
          {
            float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.worldPos));
            float3 vDirWS = normalize(UnityWorldSpaceViewDir(i.worldPos));

            float3 nDirTS = UnpackNormal(tex2D(_BumpTex,i.uv));
            float3x3 TBN = float3x3(i.worldTangent,i.worldBiTangent,i.worldNormal);
            float3 nDirWS = mul(nDirTS,TBN);

            float3 vrDirWs = reflect(-vDirWS,nDirWS);

            float4 mainTex = tex2D(_MainTex,i.uv);
            float4 speTex = tex2D(_SpeTex,i.uv);
            float3 effectTex = tex2D(_Effect01,i.uv1);

            float shadow = LIGHT_ATTENUATION(i);

            float3 baseColor = mainTex.rgb * max(0.0,dot(lDirWS,nDirWS));
            float3 specular = speTex.rgb * pow(max(0.0,dot(vrDirWs,lDirWS)),lerp(1.0,_SpePow,speTex.a));
            float3 dirLight =  (baseColor+specular)*shadow;

            float3 envColor = ThreeColor(nDirWS,_TopColor.rgb,_SideColor.rgb,_DownColor.rgb);
            float fresnel = pow(1-dot(vDirWS,nDirWS),_FresnelPow);
            float3 cubeTex = texCUBElod(_CubeMap,float4(vrDirWs,lerp(_CubeMapLevel,0.0,speTex.a))).rgb;
            float3 envLight = (envColor*mainTex.rgb*_EnvIntensity+cubeTex*fresnel)*mainTex.a;

            float meshOpacity = max(0,floor(min(0.99999,effectTex.g)+i.effectMask.g));
            float slopeOpacity = max(0,floor(min(0.99999,effectTex.b)+i.effectMask.b));
            float opacity = lerp(1.0,min(meshOpacity,slopeOpacity),i.effectMask.w);

            float meshEmitInt = (i.effectMask.z - i.effectMask.x)*effectTex.x;
            meshEmitInt *=meshEmitInt;
            float3 effectColor = _EffectColor.rgb * meshEmitInt * i.effectMask.w; 

            float3 finalColor = dirLight + envLight + effectColor;

            return float4(finalColor*opacity,opacity);
          }

          ENDCG
        }
    }
}
