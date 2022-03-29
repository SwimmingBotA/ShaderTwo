// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/Old"
{
    Properties
    {
      _BaseColor("BaseColor",Color)=(1.0,1.0,1.0,1.0)
      _SpecularColor("SpecularColor",Color)=(1.0,1.0,1.0,1.0)
      _Glass("Glass",Range(0.0,20.0))=8.0 
      _BumpTex("BumpTex",2D)="bump"{}
      _TopColor("TopColor",Color)=(1.0,1.0,1.0,1.0)
      _SideColor("SideColor",Color)=(1.0,1.0,1.0,1.0)
      _DownColor("DownColor",Color)=(1.0,1.0,1.0,1.0)
      _OcculustionTex("OcculustionTex",2D)="white"{}
      _EnvIntensity("EnvIntensity",Range(0.0,20.0))=1.0
      _CubeTex("CubeTex",Cube)="_SkyBox"{}
      _MipmapLevel("MipmapLevel",Range(0.0,10.0))= 0.0
      _FresnelPow("FresnelPow",Range(0.0,10.0))=1.0
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
            #pragma multi_compile_fwdbase_fullshadow

            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _BaseColor;
            fixed4 _SpecularColor;
            float _Glass;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;

            fixed4 _TopColor;
            fixed4 _SideColor;
            fixed4 _DownColor;
            sampler2D _OcculustionTex;
            float _EnvIntensity;
            samplerCUBE _CubeTex;
            float _MipmapLevel;
            float _FresnelPow;


            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv0 : TEXCOORD0;
                float2 uv1:TEXCOORD1;
                float2 uv2:TEXCOORD2;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBiTangent : TEXCOORD3;
                float2 uv0 : TEXCOORD4;
                float2 uv1 : TEXCOORD5;
                LIGHTING_COORDS(6,7)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                o.worldTangent = normalize(mul(unity_ObjectToWorld,v.tangent).xyz);
                o.worldBiTangent = normalize(cross(o.worldNormal,o.worldTangent)*v.tangent.w);
                o.uv0 = TRANSFORM_TEX(v.uv0,_BumpTex);
                o.uv1 = v.uv1;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                 
                //切线空间法线转世界空间法线
                float3 tangentNormal = UnpackNormal(tex2D(_BumpTex,i.uv0));
                float3x3 TBN = float3x3(i.worldTangent,i.worldBiTangent,i.worldNormal);
                float3 worldNormalDir = mul(tangentNormal,TBN);

                //基于法线纹理的法线做反射
                float3 worldRefViewDir =  reflect(-worldViewDir,worldNormalDir);

                //直接光照
                float3 diffuse = _BaseColor.rgb * max(0,dot(worldNormalDir,worldLightDir));

                //高光
                float3 specular = _SpecularColor * pow(max(0,dot(worldRefViewDir,worldLightDir)),_Glass);

               //fresnel
                float fresnel = pow(max(0.3,1-dot(worldViewDir,worldNormalDir)),_FresnelPow);

                //间接光照
                float top = max(0,worldNormalDir.g);
                float down = max(0,-worldNormalDir.g);
                float side = 1.0 - top - down;
                float3 envColor = top * _TopColor.rgb + side * _SideColor.rgb + down * _DownColor.rgb;
                float occulustion = tex2D(_OcculustionTex,i.uv1);
                float3 envCube = texCUBElod(_CubeTex,float4(worldRefViewDir,_MipmapLevel)).rgb;
                float3 envDiffuse = (envColor * _BaseColor.rgb * _EnvIntensity + envCube  * fresnel) * occulustion ;
               
               float shadow = LIGHT_ATTENUATION(i);

                
                float3 finalColor = (diffuse  + specular) * shadow + envDiffuse;
            
                return float4(finalColor,1.0);
            }


            ENDCG
 
        }
    }
    FallBack "Diffuse"
}
