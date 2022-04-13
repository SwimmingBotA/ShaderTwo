// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/Clock"
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
     [Header(RotateAngle)]
        _SRotateID("SRotateID",float)=0.0
        _MRotateID("MRotateID",float)=0.0
        _HRotateID("HRotateID",float)=0.0
        _Offset("Offset",float)=0.0
    }
    SubShader
    {
        Pass
        {
           Tags
           { 
           "LightMode"="ForwardBase"
           "RenderType"="Opaque"
           }
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

           float _SRotateID;
           float _MRotateID;
           float _HRotateID;
           half _Offset;

           struct a2v
           {
             float4 vertex:POSITION;
             float3 normal:NORMAL;
             float4 tangent:TANGENT;
             float3 color:COLOR;
             float2 uv:TEXCOORD0;
           };

           struct v2f
           {
             float4 pos:SV_POSITION;
             float3 worldPos:TEXCOORD0;
             float3 worldNormal:TEXCOORD1;
             float3 worldTangent:TEXCOORD2;
             float3 worldBiTangent:TEXCOORD3;
             float3 color:TEXCOORD4;
             float2 uv:TEXCOORD5;
             LIGHTING_COORDS(6,7)
           };


           void RotateAngle(float mask,inout float3 vertex,float angle,float offset)
           {
              vertex.y -=offset*mask;
              float radZ = angle * mask;
              float cosZ;
              float sinZ;
              sincos(radZ,sinZ,cosZ);
              vertex.xy = float2
              (
                vertex.x * cosZ - vertex.y * sinZ,
                vertex.x * sinZ + vertex.y * cosZ
              );
              vertex.y +=offset*mask;
           }

           void Rotating(float3 color,inout float3 vertex,float s,float m,float h,float offset)
           {
               RotateAngle(color.b ,vertex ,s ,offset);
               RotateAngle(color.g ,vertex ,m ,offset);
               RotateAngle(color.r ,vertex ,h ,offset);   
           }


           v2f vert(a2v v)
           {
             v2f o;
             Rotating(v.color,v.vertex.xyz,_SRotateID,_MRotateID,_HRotateID,_Offset);
             o.pos = UnityObjectToClipPos(v.vertex);
             o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
             o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
             o.worldTangent = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
             o.worldBiTangent = normalize(cross(o.worldNormal,o.worldTangent)*v.tangent.w);
             o.uv = TRANSFORM_TEX(v.uv,_MainTex);
             o.color = v.color;
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

            float shadow = LIGHT_ATTENUATION(i);

            float3 baseColor = mainTex.rgb * max(0.0,dot(lDirWS,nDirWS));
            float3 specular = speTex.rgb * pow(max(0.0,dot(vrDirWs,lDirWS)),lerp(1.0,_SpePow,speTex.a));
            float3 dirLight =  (baseColor+specular)*shadow;

            float3 envColor = ThreeColor(nDirWS,_TopColor.rgb,_SideColor.rgb,_DownColor.rgb);
            float fresnel = pow(1-dot(vDirWS,nDirWS),_FresnelPow);
            float3 cubeTex = texCUBElod(_CubeMap,float4(vrDirWs,lerp(_CubeMapLevel,0.0,speTex.a))).rgb;
            float3 envLight = (envColor*mainTex.rgb*_EnvIntensity+cubeTex*fresnel)*mainTex.a;

            float3 finalColor = dirLight + envLight;

            return float4(finalColor,1.0);
          }

          ENDCG
        }
    }
}
