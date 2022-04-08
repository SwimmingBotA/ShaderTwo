// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/UVFire"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "blue" {}
        _Noise("Noise",2D)="gray"{}
        _Noise1Set("Noise1 X:Size  Y:Speed Z:Intensity",Vector)=(1.0,1.0,1.0,1.0)
        _Noise2Set("Noise2 X:Size  Y:Speed Z:Intensity",Vector)=(1.0,1.0,1.0,1.0)
        [HDR]_SideColor("SideColor",Color)=(1.0,1.0,1.0,1.0)
        [HDR]_InSideColor("InSideColor",Color)=(1.0,1.0,1.0,1.0)
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
                o.uv0 = v.uv ;
                o.uv1 = v.uv.xy * _Noise1Set.x - float2(0.0,frac(_Time.x * _Noise1Set.y));
                o.uv2 = v.uv.xy * _Noise2Set.x - float2(0.0,frac(_Time.x * _Noise2Set.y));
                return o;
           }

           float4 frag(v2f i):SV_Target
           {
                half noise1Tex = tex2D(_Noise,i.uv1).r;
                half noise2Tex = tex2D(_Noise,i.uv2).g;
                half2 mainMask = tex2D(_MainTex,i.uv0).ba;

                half noise = noise1Tex * _Noise1Set.z + noise2Tex * _Noise2Set.z;

                float2 uv = i.uv0 - float2(0.0,noise)*mainMask.x;

                half2 mainTex = tex2D(_MainTex,uv).rg;



                half opacity = mainTex.r+mainTex.g;

                half3 finalColor = mainTex.r * _SideColor + mainTex.g * _InSideColor;

                return float4(finalColor,opacity);
           }

           ENDCG


        }
    }
}
