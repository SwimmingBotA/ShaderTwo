// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/FakeReflect"
{
    Properties
    {
        _RampTex("RampTex",2D)="white"{}
        _MainColor("MainColor",Color)=(1,1,1,1)
        _Strength("Strength",Range(0.0,1.0))=0.1
        _SpecularColor("SpecularColor",Color)=(1,1,1,1)
        _Glass("Glass",Range(0,255))=8.0
    }
    SubShader
    {

        Pass
        {
           Tags { 
           "RenderType"="Opaque"
           "LightMode"="ForwardBase"
           }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            sampler2D _RampTex;
            fixed _Strength;
            fixed4 _SpecularColor;
            float _Glass;
            fixed4 _MainColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0; 
                float3 worldPositon:TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPositon = mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float3 worldNormalDirection = normalize(i.worldNormal);
                float3 worldLightDirection = normalize(UnityWorldSpaceLightDir(i.worldPositon));
                float3 worldViewDirection = normalize(UnityWorldSpaceViewDir(i.worldPositon));
                float3 worldReflectDirection = normalize(reflect(-worldLightDirection,worldNormalDirection));
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                float vr = dot(worldReflectDirection,worldViewDirection)* 0.5 + 0.5;

                float3 diffuse = 
                _LightColor0.rgb * _MainColor.rgb * tex2D(_RampTex,float2(vr,_Strength));

                float3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(worldReflectDirection,worldViewDirection)),_Glass);

                return float4(ambient+specular+diffuse,1.0);
            }
            ENDCG
        }
    }
}
