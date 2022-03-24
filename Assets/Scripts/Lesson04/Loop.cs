using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Loop : MonoBehaviour
{
    new Renderer renderer;
    Material sss;
    [SerializeField] float durationTime;

    private void Awake()
    {
        renderer = GetComponent<Renderer>();
        sss = renderer.material;

        if (sss == null)
        {
            this.enabled = false;
        }
        else
        {
            sss.SetFloat("_Strength", 0f);
        }
    }

    IEnumerator Start()
    {
        while (isActiveAndEnabled)
        {
            yield return StartCoroutine(LoopFloat(0f, 1f));
            yield return StartCoroutine(LoopFloat(1f, 0f));
        }
    }

    IEnumerator LoopFloat(float first,float last)
    {
        float t = 0;
        while (t <= 1f)
        {
            t += Time.deltaTime / durationTime;
            sss.SetFloat("_Strength", Mathf.Lerp(first,last,t));
            yield return null;
        }
    }
}
