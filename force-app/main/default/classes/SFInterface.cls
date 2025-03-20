/**********************************************************************
 名    称：SFInterface
 目    的：接口定义类
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2019-01-15
 修 改 人：
 修改日期：
 修改原因：
 备    注：
 **********************************************************************/
global without sharing class SFInterface {

    /*
        导入验证接口，在导入数据时，需要对数据进行校验，可实现此接口。
        在导入配置信息中配置"验证类名"的类名来达到导入前对数据进行验证。
    */
    public interface SFImportValidateInterface {

        /**********************************************************************
         名称：validate
         目的：在导入数据前，对数据进行校验
         参数：sobjectName - 要检验数据的对象Api名称
               sourceDataMap - 要校验的数据
                               key - rowIndex
                               value - Sobject
         返回：校验后的返回数据
         **********************************************************************/
        Map<Integer, SFImportRow> validate(String sobjectName, Map<Integer, Sobject> sourceDataMap);
    }

    /*
        导入数据处理接口，在保存导入数据前，如果需要对数据进行预处理，可实现此接口。
        在导入配置信息中配置"数据预处理类"的类名来达到导入前对数据进行预处理。
    */
    public interface SFImportFixedInterface {

        /**********************************************************************
         名称：preProcess
         目的：保存导入数据前，对数据进行预处理
         参数：sobjectName - 对象Api名称
               sourceDataList - 要保存的数据集合
         返回：
         **********************************************************************/
        void preProcess(String sobjectName, List<SObject> sourceDataList);
    }
}