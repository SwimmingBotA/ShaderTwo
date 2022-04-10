Shader "Ariaaaaa/Polar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
        [HDR]_Color("Color",Color)=(1.0,1.0,1.0,1.0)
        _Speed("Speed",Range(0.0,10.0))=1.0
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
          float4 _MainTex_ST;

          float4 _Color;
          half _Opacity;
          half _Speed;

          struct a2v
          {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
              float4 color:COLOR;
          };

          struct v2f
          {
              float4 pos:SV_POSITION;
              float2 uv:TEXCOORD0;
              float4 color:COLOR;
          };

          v2f vert(a2v v)
          {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv,_MainTex);
            o.color = v.color;
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            i.uv = i.uv - 0.5;
            float theta = atan2(i.uv.y,i.uv.x);
            theta = (theta/3.1415926) * 0.5 + 0.5;
            float r = length(i.uv) + frac(_Time.x *_Speed);
            i.uv = float2(theta,r);

            float4 mainTex = tex2D(_MainTex,i.uv);

            float3 finalColor = (1-mainTex.rgb)*_Color;

            float opacity = (1-mainTex.r) * _Opacity * i.color.r;

            return float4(finalColor*opacity,opacity);
          }
          ENDCG
        }
    }
}
