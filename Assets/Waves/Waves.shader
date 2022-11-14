Shader "Custom/Waves"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
//        _Steepness ("Steepness", Range(0,1)) = 0.5
//        _Wavelength ("Wavelength", Float) = 10
//        _Direction ("Direction 2D", Vector) = (1,0,0,0)
        _FirstWave ("First wave(direction, steepness,wavelength)", Vector) = (1,0,0.5,10)
        _SecondWave ("Second wave(direction, steepness,wavelength)", Vector) = (0,1,0.25,20)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        // float _Steepness;
        // float _Wavelength;
        // float2 _Direction;
        float4 _FirstWave;
        float4 _SecondWave;

        float3 GerstnerWave(
            float4 wave, float3 gridPoint, inout float3 tangent, inout float3 binormal)
        {
            //Creating waves with movement, curve and move the surface.
            float steepness = wave.z;
            float wavelength = wave.w;
            float waveNumber = 2 * UNITY_PI / wavelength;
            float phaseSpeed = sqrt(9.8 / waveNumber);
            float2 direction = normalize(wave.xy);
            float f = waveNumber * (dot(direction,gridPoint.xz) - phaseSpeed * _Time.y);
            float amplitude = steepness / waveNumber;

            //Adjust normal vectors to create a vertical surface.
            tangent += float3(
                -direction.x * direction.x * (steepness * sin(f)),
                direction.x * (steepness * cos(f)),
                -direction.x * direction.y * (steepness * sin(f))
                );

            binormal += float3(
                -direction.x * direction.y * (steepness * sin(f)),
                direction.y * (steepness * cos(f)),
                -direction.y * direction.y * (steepness * sin(f))
                );

            return float3(
                direction.x * (amplitude * cos(f)),
                amplitude * sin(f),
                direction.y * (amplitude * cos(f))
                );
        }
        
        void vert(inout appdata_full vertexData)
        {
            float3 gridPoint = vertexData.vertex.xyz;
            float3 tangent = float3(1,0,0);
            float3 binormal = float3(0,0,1);
            float3 finalPos = gridPoint;
            finalPos += GerstnerWave(_FirstWave, gridPoint, tangent, binormal);
            finalPos += GerstnerWave(_SecondWave, gridPoint, tangent, binormal);
            float3 normal = normalize(cross(binormal, tangent));
            vertexData.vertex.xyz = finalPos;
            vertexData.normal = normal;
        }

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
