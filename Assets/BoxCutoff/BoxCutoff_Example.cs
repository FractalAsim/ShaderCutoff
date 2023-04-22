using UnityEngine;

[ExecuteInEditMode]
public class BoxCutoff_Example : MonoBehaviour
{
    public bool Enable;
    public bool Reverse;
    public GameObject cutoffGO;

    void Update()
    {
        Vector3 halfsize = transform.lossyScale / 2;
        Vector3 pos = transform.position;
        Vector3 min = pos - halfsize;
        Vector3 max = pos + halfsize;

        cutoffGO.GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_Enable", Enable ? 1 : 0);
        cutoffGO.GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_Reverse", Reverse ? 1 : 0);

        cutoffGO.GetComponent<MeshRenderer>().sharedMaterial.SetVector("_Min", min);
        cutoffGO.GetComponent<MeshRenderer>().sharedMaterial.SetVector("_Max", max);
    }
    void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }
}
