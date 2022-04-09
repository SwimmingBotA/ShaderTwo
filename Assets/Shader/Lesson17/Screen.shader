// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/Screen"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScreenTex("ScreenTex",2D)="white"{}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
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
          Blend One OneMinusSrcAlpha
          CGPROGRAM
          #pragma vertex vert
          #pragma fragment frag
          //#pragma multi_compile_fwdbase_fullshadow

          #include "UnityCG.cginc"
          #include "AutoLight.cginc"
          #include "Lighting.cginc"

          sampler2D _MainTex;
          sampler2D _ScreenTex;
          float4 _ScreenTex_ST;

          half _Opacity;

          struct a2v
          {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
          };

          struct v2f
          {
              float4 pos:SV_POSITION;
              float2 uv:TEXCOORD0;
              float2 screenUV:TEXCOORD1;
              float3 vp:TEXCOORD2;
          };

          v2f vert(a2v v)
          {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            
            o.uv =v.uv;
            float3 viewSpacePosition = UnityObjectToViewPos(v.vertex).xyz;
            o.screenUV = viewSpacePosition.xy/viewSpacePosition.z;
            float distance = UnityObjectToViewPos(float3(0.0,0.0,0.0)).z;
            o.screenUV *=distance;
            o.screenUV = o.screenUV*_ScreenTex_ST.xy + frac(_Time.x*_ScreenTex_ST.zw);
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            
            half screenTex = tex2D(_ScreenTex,i.screenUV);
            half4 mainTex = tex2D(_MainTex,i.uv);

            half opacity = _Opacity * mainTex.a * screenTex;

            return float4(mainTex.rgb*opacity,opacity);
          }
          ENDCG
        }
    }
}
