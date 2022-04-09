// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/Grab"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _UVOffset("UVOffset",Range(0.0,1.0))=1.0
        _BiasInt("BiasInt",Range(0.0,3.0))=1.0
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

        
        GrabPass
        {
            "_BGTex"
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
          sampler2D _BGTex;

          half _Opacity;
          half _UVOffset;
          half _BiasInt;

          struct a2v
          {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
          };

          struct v2f
          {
              float4 pos:SV_POSITION;
              float2 uv:TEXCOORD0;
              float4 grabPos:TEXCOORD1;
          };

          v2f vert(a2v v)
          {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            
            o.uv =v.uv;
            
            o.grabPos = ComputeGrabScreenPos(o.pos);

            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            
            half4 mainTex = tex2D(_MainTex,i.uv);

            i.grabPos.xy += (mainTex.b - _UVOffset)*_BiasInt * _Opacity;

            half3 bgTex = tex2Dproj(_BGTex,i.grabPos).rgb;

            half3 finalColor = lerp(1.0,mainTex.rgb,_Opacity) * bgTex;

            half opacity = mainTex.a;

            return float4(finalColor * opacity,opacity);
          }
          ENDCG
        }
    }
}
