// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/UVTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise("Noise",2D)="gray"{}
        _TestOffset("TestOffset",Range(-1.0,1.0))=0.0
    }
    SubShader
    {
        Tags 
        {
        "Queue"="Transparent"
        "RenderType"="TransparentCutout"
        "ForceNoShadowCasting"="True"
        "IgnoreProjector"="True"  
        }

        Pass
        {
           Tags
           {
           "LightMode"="ForwardBase"
           }
           Cull Off

           Blend One OneMinusSrcAlpha

           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           //#pragma multi_compile_fwdbase_fullshadow
           
           #include "UnityCG.cginc"
           //#include "Lighting.cginc"
           //#include "AutoLight.cginc"

           sampler2D _MainTex;
           sampler2D _Noise;
           float4 _Noise_ST;

           half _TestOffset;

           struct a2v
           {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
           };

           struct v2f
           {
                float4 pos:SV_POSITION;
                float2 uv0:TEXCOORD0;
                float2 uv1:TEXCOORD1;
           };

           v2f vert(a2v v)
           {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv ;
                o.uv1 = TRANSFORM_TEX(v.uv,_Noise);
                //o.uv1.x = o.uv1.x + frac(_Time.x);
                return o;
           }

           float4 frag(v2f i):SV_Target
           {
                float noiseTex = tex2D(_Noise,i.uv1).r;
                float2 uv0 = i.uv0 + float2(noiseTex+_TestOffset,0);

                float3 baseColor = tex2D(_MainTex,i.uv0);

                float3 biasColor = tex2D(_MainTex,uv0);

                return float4(biasColor,1.0);
           }

           ENDCG


        }
    }
}
