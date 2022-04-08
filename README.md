# ShaderTwo

连连看写成代码形式加深印象，上个库太乱了，重搞一个

玩了一个星期的Shader Graph，发现自己写shader能力变拉了

所以连连看虽好，但要丢进垃圾桶里哦

![图片](https://user-images.githubusercontent.com/50166070/159422407-f43d457b-81f6-4664-93cf-10feeea81481.png)


### [简易SSS](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson04)

keyword：tex2D(_SSSTexture,fixed2(diff,_Strength))


![gif_01](https://user-images.githubusercontent.com/50166070/160222290-b4ce87c8-340e-4657-93c5-3edcdf690368.gif)


### [FakeReflect](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson06)

![图片](https://user-images.githubusercontent.com/50166070/160222130-44dc11cf-11a3-4a00-99e6-ed1e27b6b781.png)

keyword：高光 = ViewDir dot LightRefDir     或者       BP：   normalize（LightDir+ViewDir） dot normalDir


我的老机器烘培一次好久啊，瞎搞几个小时，光的弹射次数一多，电表倒转，可惜，以后在烘培吧

![图片](https://user-images.githubusercontent.com/50166070/160242111-63f4b5c5-67f3-4e8f-a74f-cf4297f3bb41.png)

### [法线贴图重映射](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson08)

![图片](https://user-images.githubusercontent.com/50166070/160747167-c5cd6c84-019d-41a3-a625-db095b85b2ea.png)

keyword：切线空间转换       UnpackNormal(tex2D(_BumpTex,i.uv))将存储在法线纹理上切线空间的法线信息拿出来，然后通过TBN矩阵转换为世界空间的法线

### [Fake模拟环境光](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson7)

![图片](https://user-images.githubusercontent.com/50166070/160747344-c60a773f-3535-453a-96c0-fcdadc7da590.png)

keyword：利用法线信息取方向

### [CubeMap与MatCap](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson9)

![图片](https://user-images.githubusercontent.com/50166070/160747487-a1ba953d-c923-42a0-ad3c-b364bfdcfcd1.png)

keyword：CubeMap 由ViewRefDir采样
         MatCap 由法线转换到ViewSpace映射采样

### [各通道运用将以上大融合为仿PBR](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson10)

![图片](https://user-images.githubusercontent.com/50166070/160747627-7b17fd4c-0eb0-4266-b23c-d51cc0c0e448.png)


### [Dota2](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Dota/TA)

![图片](https://user-images.githubusercontent.com/50166070/161924289-e219c628-9cbb-41af-82e6-9b526f7c0d6e.png)

摸了个十年前dota2的人物模型实现方法，当时受限于硬件、技术，并没有用高性能的实时算法，而是用了各种烘培与贴图实现人物的表现，不得不再次佩服美术啊


### [Blend](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson13)

![图片](https://user-images.githubusercontent.com/50166070/161969680-ee036273-8a53-4a3f-b786-7560a7c26279.png)

O<sub>rgb</sub> = SrcFactor * S<sub>rgb</sub> + DstFactor * D<sub>rgb</sub>

O<sub>a</sub> = SrcFactorA * S<sub>a</sub> + DstFactorA * D<sub>a</sub>

### [UV](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson15)

![gif_animation_007](https://user-images.githubusercontent.com/50166070/162391029-b713a59e-4bd3-4612-9741-e36fe7bc73e2.gif)


### [FireAndWater](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Lesson16)

![gif_animation_006](https://user-images.githubusercontent.com/50166070/162391008-dd749fa8-ff2e-4070-acd5-d16ab40de769.gif)


### [Extra](https://github.com/oneputatoT/ShaderTwo/tree/main/Assets/Shader/Extra)

![gif_animation_004](https://user-images.githubusercontent.com/50166070/161925539-d9fe45e5-8b95-445f-8d0d-f399530155a9.gif)


