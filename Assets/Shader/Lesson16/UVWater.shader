// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/UVWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "blue" {}
        _Noise("Noise",2D)="gray"{}
        _WaterSpeed("WaterSpeed",Range(-10,10))=1.0
        _Noise1Set("Noise1 X:Size  Y:XSpeed Z:YSpeed W:Intensity",Vector)=(1.0,1.0,1.0,1.0)
        _Noise2Set("Noise2 X:Size  Y:XSpeed Z:YSpeed W:Intensity",Vector)=(1.0,1.0,1.0,1.0)
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
           float4 _MainTex_ST;
           sampler2D _Noise;
           
           half _WaterSpeed;
           half4 _Noise1Set;
           half4 _Noise2Set;

           half4 _SideColor;
           half4 _InSideColor;

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
                float2 uv2:TEXCOORD2;
           };

           v2f vert(a2v v)
           {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv,_MainTex);
                o.uv0 = o.uv0 + frac(_Time.x * _WaterSpeed);
                o.uv1 = v.uv.xy * _Noise1Set.x - frac(_Time.x * _Noise1Set.yz);
                o.uv2 = v.uv.xy * _Noise2Set.x - frac(_Time.x * _Noise2Set.yz);
                return o;
           }

           float4 frag(v2f i):SV_Target
           {
                half noise1Tex = tex2D(_Noise,i.uv1).r;
                half noise2Tex = tex2D(_Noise,i.uv2).g;
                half3 mainMask = tex2D(_MainTex,i.uv0).rgb;

                half noise = (noise1Tex-0.5) * _Noise1Set.w + (noise2Tex-0.5) * _Noise2Set.w;

                float2 uv = i.uv0 - float2(0.0,noise);

                half3 mainTex = tex2D(_MainTex,uv).rgb;

                return float4(mainTex,1.0);
           }

           ENDCG


        }
    }
}
