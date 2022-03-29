// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/ThreeColor"
{
    Properties
    {
        _OcculusionTex ("OcculusionTex", 2D) = "white" {}
        _BassColor("BaseColor",Color)=(1,1,1,1)
        _TopColor("TopColor",Color)=(1,1,1,1)
        _SideColor("SideColor",Color)=(1,1,1,1)
        _DownColor("DownColor",Color)=(1,1,1,1)
        _Strength("Strength",Range(0.0,1.0))=0.1
        _SpecularColor("SpecularColor",Color)=(1,1,1,1)
        _LightColor("LightColor",Color)=(1,1,1,1)
        _Glass("Glass",Range(0,255))=8.0
        
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
            #pragma multi_compile_fwdbase_fullshadows

            #include "UnityCG.cginc"

            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            sampler2D _OcculusionTex;
            float4 _OcculusionTex_ST;

            fixed4 _TopColor;
            fixed4 _SideColor;
            fixed4 _DownColor;
            fixed4 _SpecularColor;
            fixed4 _BassColor;
            fixed4 _LightColor;
            fixed _Strength;

            float _Glass;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPositon:TEXCOORD1;
                float2 uv:TEXCOORD2;
                LIGHTING_COORDS(3,4)      //阴影
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPositon = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv,_OcculusionTex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float3 worldNormalDir = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPositon));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPositon));

                //模拟环境光
                float topNormalDir = max(0,worldNormalDir.g);
                float downNormalDir = max(0,-worldNormalDir.g);
                float sideNormalDir = 1.0 - topNormalDir - downNormalDir;

                float3 environmentColor = _TopColor.rgb * topNormalDir + _SideColor.rgb * sideNormalDir
                                           + _DownColor.rgb * downNormalDir;

                float albedo = tex2D(_OcculusionTex,i.uv);
                
                //EnvironmentDiffuse
                float3 envDiffuse = environmentColor * albedo * _Strength * _BassColor.rgb ;

                //diffuse
                float3 diffuse = _LightColor.rgb *_BassColor.rgb * max(0,dot(worldLightDir,worldNormalDir));

                //specular
                float3 specular = _SpecularColor.rgb * _LightColor.rgb *
                pow(max(0,dot(normalize(worldLightDir+worldViewDir),worldNormalDir)),_Glass);

                float shadow = LIGHT_ATTENUATION(i);

                return float4((diffuse+ specular)* shadow + envDiffuse,1);
            }

            ENDCG
 
        }
    }
    FallBack "Diffuse"
}
