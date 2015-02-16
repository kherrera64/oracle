using System;
using System.Collections.Generic;
using System.Web;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Oracle.DataAccess.Client;
using Oracle.DataAccess.Types;
using System.Data;
using System.Configuration;
using System.Web.Services;
using System.Web.UI.HtmlControls;
using Newtonsoft.Json;
using System.Text.RegularExpressions;
using Microsoft.Reporting.WebForms;

/*- Modificacion - Se agrego el viewport para que funcione el tamaño de bootstrap predeterminado en dispositivos moviles y el WebMethod
*                de enviar los parametros para solicitudDecidevista.aspx, y se compuso que en la tabla de cursos aparesca la seccion.
  - Modificacion - Edy Cocon - 29-01-2014 -
        Se redujo el tamaño a las celdas de las tablas y se arreglo el link de Recibo para que puedan ser copiados.
 - Modificacion - Edy Cocon - 11-02-2014 -
          Válida que si los session de carne y carrera llevan valor se redireccione a la misma página pero con los parámetros en la URL,
         Se agregó una consulta al storedProcedure de dbafisicc.edocta.LLENAEDOCTA antes de llenar los labels de saldo y Se agregó el 
 *          control de Script. 
 * Modificación - Edy Cocon - Se quito a que sumara las multas con el saldo de hoy ya que ahora se incluyen en la tabla de Resumen.
 * Modificación - Edy Cocon - Se agregó el metodo de  validacarrera ya que daba error cuando el alumno no tiene la carrera asignada y
 *                            se compuso la forma de abrir un recibo ya que no existia la variable correlativo.
 * Modificacion - Edy Cocon - Se eliminó el curso para la tabla de resumen y se aplica group by.
 *12-06-2014
 *Modificacion - Edy Cocon - Se agrego un nuevo reporte para Estado de Cuenta llamado RepCuenta.rdlc, Y Ahora muestra el campo centro. 
 - 07/07/2014 -  Edy Cocon - Se reemplazo la consulta a DBAFISICC.EDOCTA.LLENAEDOCTA por DBAFISICC.LLAMASALDO_A_HOY_WEB ya que en la anterior
 *                           no llenaba la tabla de dbafisicc.cchedoctadetalletb para todos los centros.
 */

public partial class Sistema_Cuenta : System.Web.UI.Page
{
    OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);

    protected void Page_Load(object sender, EventArgs e)
    {
        dvBecaSi.Visible = false;
        dvBecaNo.Visible = false;

        exoneracion.Visible = true;
        fraccionamiento.Visible = true;

        string user = Convert.ToString(Session["Usuario"]);
        pcarnet = Request.QueryString["carnet"];
        pcarrera = Request.QueryString["carrera"];
        string SessCarr = Convert.ToString(Session["carrera"]);
        string SessCarne = Convert.ToString(Session["carne"]);

        if (user != string.Empty)
        {
            if (pcarrera != null)
            {
                if (pcarnet != null)
                {
                    if (pcarrera != "")
                    {
                        if (pcarnet != "")
                        {
                            validacarrera(pcarnet, Convert.ToString(Session["Usuario"]), pcarrera);
                            Session["carrera"] = pcarrera;
                            Session["carne"] = pcarnet;
                            pcarrera = pcarrera.ToUpper();
                            llenarCuotas(pcarrera, pcarnet, user);
                            llenarSaldos(pcarrera, pcarnet, user);
                            llenar_labels(pcarrera, pcarnet);
                            if (lblTotalPagar.InnerText == "")
                            {
                                lblTotalPagar.InnerText = "Q.0.00";
                            }

                            if (beca(pcarrera, pcarnet))
                            {
                                dvBecaSi.Visible = true;
                                llenar_beca(pcarrera, pcarnet, user);
                            }
                            else
                            {
                                dvBecaNo.Visible = true;
                            }
                        }
                        else
                        {
                            if (SessCarr == "" && SessCarne == "")
                            {
                                Response.Redirect("Default.aspx");
                            }
                            else
                            {
                                Response.Redirect("Cuenta.aspx?carnet=" + SessCarne + "&carrera=" + SessCarr);
                            }
                        }

                    }
                    else
                    {
                        if (SessCarr == "" && SessCarne == "")
                        {
                            Response.Redirect("Default.aspx");
                        }
                        else
                        {
                            Response.Redirect("Cuenta.aspx?carnet=" + SessCarne + "&carrera=" + SessCarr);
                        }
                    }
                }
                else
                {
                    if (SessCarr == "" && SessCarne == "")
                    {
                        Response.Redirect("Default.aspx");
                    }
                    else
                    {
                        Response.Redirect("Cuenta.aspx?carnet=" + SessCarne + "&carrera=" + SessCarr);
                    }
                }
            }
            else
            {

                if (SessCarr == "" && SessCarne == "")
                {
                    Response.Redirect("Default.aspx");
                }
                else
                {
                    Response.Redirect("Cuenta.aspx?carnet=" + SessCarne + "&carrera=" + SessCarr);
                }
            }
        }
        else
        {
            Response.Redirect("/Login.aspx");
        }
    }

    public string pcarrera;
    public string pcarnet;
    public string ptotalpagar;

    //23-05-2014  Se agregó el Método.
    /// <summary>
    /// Metodo que Valida si la carrera del alumno no esta agregada en dbafisicc.caalumcarrstb envie a la página de buscar.aspx ya 
    /// que da error cuando un alumno entra desde portales y no tiene agregada la carrera.
    /// </summary>
    /// <param name="carne"></param>
    /// <param name="usuario"></param>
    /// <param name="carrera"></param>
    protected void validacarrera(string carne, string usuario, string carrera)
    {
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_CARRERA.SEL_CARRERANOASIGNADA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PUSUARIO", usuario);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (Convert.ToString(dt.Rows[i]["CARRERA"]) == carrera)
                {

                    Response.Redirect("Buscar.aspx");
                }

            }

            da.Dispose();
        }
        catch (Exception ex)
        {
            Response.Redirect("Buscar.aspx");
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

    /// <summary>
    ///  Metodo que sirve para llenar el label de total a pagar del ciclo.
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    protected void llenar_labels(string carrera, string carne)
    {

        decimal saldo = Convert.ToDecimal(lblSalSugerido.InnerText.Substring(2, lblSalSugerido.InnerText.Length - 2));
        decimal multas = 0;
        decimal total;

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.MULTASEDOCTA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PEDOCTA", "0");

        try
        {
            cn.Open();
            cmd.ExecuteNonQuery();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.SEL_MULTASTMP";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PUSUARIO", Session["Usuario"].ToString());
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                multas += Convert.ToDecimal(dt.Rows[i]["MONTO"]);
            }

            da.Dispose();
        }
        catch (Exception ex)
        {
            Response.Redirect("Default.aspx");
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        lblTotalMultas.InnerText = "Q." + multas.ToString("0.00");
        total = saldo;
        lblPagarHoy.InnerText = "Q." + total.ToString("0.00");
    }


    /// <summary>
    /// Metodo que llena la tabla de Multas. 
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    /// <returns>Devuelve un Json con el DataTable que llena el StoredProcedure dbafisicc.SEL_MULTASTMP</returns>
    [WebMethod]
    public static string llenar_multas(string carrera, string carne)
    {

        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.MULTASEDOCTA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PEDOCTA", "0");

        try
        {
            cn.Open();
            cmd.ExecuteNonQuery();
        }
        catch (Exception ex)
        {
            HttpContext.Current.Response.Redirect("login.aspx");
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.SEL_MULTASTMP";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PUSUARIO", Convert.ToString(HttpContext.Current.Session["Usuario"]));
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);



            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        return Newtonsoft.Json.JsonConvert.SerializeObject(dt);

    }


    /// <summary>
    ///  Metodo que sirve para los mostrar los labels de la descripción de beca de un alumno. 
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    /// <param name="usuario"></param>
    protected void llenar_beca(string carrera, string carne, string usuario)
    {
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_BECAS.SEL_DETALLEBECA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PUSUARIO", usuario);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;
        DataTable dt = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);


            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        decimal mtpor = Convert.ToDecimal(dt.Rows[0]["PORCENTAJEMT"]);
        decimal mtcant = Convert.ToDecimal(dt.Rows[0]["CANTIDADFIJAMT"]);
        decimal ctpor = Convert.ToDecimal(dt.Rows[0]["PORCENTAJECT"]);
        decimal ctcant = Convert.ToDecimal(dt.Rows[0]["CANTIDADFIJA"]);

        lblMtCant.InnerText = mtcant.ToString("0.00");
        lblMtpor.InnerText = mtpor.ToString("0.00");
        lblCtCant.InnerText = ctcant.ToString("0.00");
        lblCtpor.InnerText = ctpor.ToString("0.00");
        lblDescBeca.InnerText = dt.Rows[0]["DESCRIPCION"].ToString();
    }

    /// <summary>
    /// Metodo que sirve para llenar la tabla de los cursos.
    /// </summary>
    /// <param name="carne"></param>
    /// <returns>Devuelve un Json con los datos que devuelve el StoredProcedure DBAFISICC.PKG_ALUMNO.SEL_CURSOSASIG</returns>
    [WebMethod]
    public static string llenar_cursos(string carne)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_ALUMNO.SEL_CURSOSASIG";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);
            da.Dispose();

            return Newtonsoft.Json.JsonConvert.SerializeObject(dt);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


    }

    /// <summary>
    /// Sirve para validar si un alumno posee beca o no.
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    /// <returns>Devuelve un Boolean. Falso: No tiene beca, True: Si tiene beca.</returns>
    protected bool beca(string carrera, string carne)
    {

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_BECAS.SEL_BECA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PUSUARIO", Convert.ToString(Session["Usuario"]));
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        string respuesta;
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);
            respuesta = Convert.ToString(cmd.ExecuteScalar());
            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        if (respuesta == "NO TIENE BECA" || respuesta == "NO")
        {
            return false;
        }
        else
        {
            return true;
        }

    }

    /// <summary>
    ///  Evento que sirve para  Response.Redirect a historiales ya sea HistorialesIdea.aspx o Historiales.aspx.
    /// </summary>
    /// <param name="send"></param>
    /// <param name="e"></param>
    protected void Historial_OnClick(object send, EventArgs e)
    {
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_CARRERA.ENTIDAD";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 4);
        cmd.Parameters.Add("PCARRERA", pcarrera);
        cmd.Parameters.Add("PUSUARIO", pcarnet);
        cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;
        string VResp;
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            VResp = Convert.ToString(cmd.Parameters["VResp"].Value);


        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        if (VResp == "02")
        {

            Response.Redirect("HistorialesIdea.aspx?carnet=" + pcarnet + "&carrera=" + pcarrera, false);
        }
        else
        {
            Response.Redirect("Historiales.aspx?carnet=" + pcarnet + "&carrera=" + pcarrera, false);
        }
    }

    /// <summary>
    ///  Metodo que sirve para mostrar la descripción de las cuotas.
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    /// <param name="usuario"></param>
    protected void llenarCuotas(string carrera, string carne, string usuario)
    {

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.SEL_CUOTAFIJA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PUSUARIO", usuario);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.SEL_CUOTAVARIABLE";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PUSUARIO", usuario);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt2 = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt2, RETVAL);

            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        decimal fija = Convert.ToDecimal(dt.Rows[0]["CUOTAFIJA"]);
        decimal variable = Convert.ToDecimal(dt2.Rows[0]["CUOTAVAR"]);
        decimal sugerida = fija + variable;
        lblCuotaFija.InnerText = "Q." + fija.ToString("0.00");
        lblCuotaVar.InnerText = "Q." + variable.ToString("0.00");
        lblCuotaSug.InnerText = "Q." + sugerida.ToString("0.00");
    }

    /// <summary>
    /// Metodo que sirve para llenar la descripción del Saldo de Un alumno.
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    /// <param name="usuario"></param>
    protected void llenarSaldos(string carrera, string carne, string usuario)
    {

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.SEL_MORA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PUSUARIO", usuario);
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.SALDOS_EXTRAORDINARIOS";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PUSUARIO", usuario);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt2 = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);


            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt2, RETVAL);

            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        decimal porctas = Convert.ToDecimal(dt.Rows[0]["MORA"]);
        decimal Extraordinario = Convert.ToDecimal(dt2.Rows[0]["SALDOSEXTR"]);
        decimal sugerido = porctas + Extraordinario;


        lblPorCtas.InnerText = "Q." + porctas.ToString("0.00");
        lblExtraordinario.InnerText = "Q." + Extraordinario.ToString("0.00");
        lblSalSugerido.InnerText = "Q." + sugerido.ToString("0.00");
    }


    /// <summary>
    /// Sirve para darle los valores a los Session de Recibo, carnetR y carreraR. Para que puedan visualizar el detalle del recibo
    /// de la página DatosRecibos.aspx
    /// </summary>
    /// <param name="recibo"></param>
    /// <param name="carne"></param>
    /// <param name="carrera"></param>
    [WebMethod]
    public static void parametros(string recibo, string carne, string carrera)
    {
        HttpContext.Current.Session["recibo"] = recibo;
        HttpContext.Current.Session["carnetR"] = carne;
        HttpContext.Current.Session["carreraR"] = carrera;
    }

    /// <summary>
    /// Sirve para la verificacion si el correlativo recibido es un tramite.
    /// </summary>
    /// <param name="correlativo"></param>
    /// <returns>Devuelve 1 si es el correlativo pertenece a un trámite y 0 si es otra cosa.</returns>
    [WebMethod]
    public static string Verificar_tramite(string correlativo)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.pkg_soltramite.SEL_SOSOLTRAMITETB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"].ToString());
        cmd.Parameters.Add("PSOLICITUD", correlativo);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            DataTable dtFinal = new DataTable("Final");

            DataColumn dc = new DataColumn();
            dc.DataType = System.Type.GetType("System.Int32");
            dc.ColumnName = "VALOR";
            dtFinal.Columns.Add(dc);

            DataRow dr;
            if (dt.Rows.Count > 0)
            {
                dr = dtFinal.NewRow();
                dr["VALOR"] = 1;
                dtFinal.Rows.Add(dr);
            }
            else
            {
                dr = dtFinal.NewRow();
                dr["VALOR"] = 0;
                dtFinal.Rows.Add(dr);
            }
            da.Dispose();
            string ret = JsonConvert.SerializeObject(dtFinal);
            return ret;

        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

    /// <summary>
    /// Metodo que sirve para enviar los parametros para SolicitudDecideVista.aspx.
    /// </summary>
    /// <param name="correlativo"></param>
    [WebMethod]
    public static void parametros_sol(string correlativo)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_PERSONAL.SEL_SOPERSONALIZARTB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCODPERS", HttpContext.Current.Session["CODPERS"].ToString());
        cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"].ToString());
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
        string mensaje;

        if (dt.Rows.Count > 0)
        {
            mensaje = dt.Rows[0]["MENSAJES"].ToString();
            if (mensaje == "")
            {
                mensaje = "0";
            }
        }
        else
        {
            mensaje = "0";
        }
        HttpContext.Current.Session["MENSAJES"] = Convert.ToInt32(mensaje);
        HttpContext.Current.Session["nosol"] = correlativo;
    }


    /// <summary>
    ///  Metodo que sirve para llenar la tabla de Resumen de un Estado de Cuenta.
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    /// <returns>Un Json con los datos que devuelve el StoredProcedure DBAFISICC.EDOCTA.RESUMEN_ESTADO_CUENTA</returns>
    [WebMethod]
    public static string llenar_resumen(string carrera, string carne)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.RESUMEN_ESTADO_CUENTA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"].ToString());
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt2 = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt2, RETVAL);

            if (dt2.Rows.Count > 0)
            {
                decimal TotalCuota = 0;
                for (int i = 0; i < dt2.Rows.Count; i++)
                {


                    if (Convert.ToString(dt2.Rows[i]["CUOTA"]) != "")
                    {
                        TotalCuota += Convert.ToDecimal(dt2.Rows[i]["CUOTA"]);
                    }
                }

                decimal totalcargos = 0;
                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    if (Convert.ToString(dt2.Rows[i]["CARGOS"]) != "")
                    {
                        totalcargos += Convert.ToDecimal(dt2.Rows[i]["CARGOS"]);
                    }
                }

                decimal totalpagos = 0;
                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    if (Convert.ToString(dt2.Rows[i]["PAGOS"]) != "")
                    {
                        totalpagos += Convert.ToDecimal(dt2.Rows[i]["PAGOS"]);
                    }
                }

                decimal totalabonos = 0;
                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    if (Convert.ToString(dt2.Rows[i]["ABONOS"]) != "")
                    {
                        totalabonos += Convert.ToDecimal(dt2.Rows[i]["ABONOS"]);
                    }
                }

                decimal totalmora = 0;
                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    if (Convert.ToString(dt2.Rows[i]["MORA"]) != "")
                    {
                        totalmora += Convert.ToDecimal(dt2.Rows[i]["MORA"]);
                    }
                }

                decimal totaladelanto = 0;
                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    if (Convert.ToString(dt2.Rows[i]["ADELANTO"]) != "")
                    {
                        totaladelanto += Convert.ToDecimal(dt2.Rows[i]["ADELANTO"]);
                    }
                }

                decimal totalsaldo = 0;
                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    if (Convert.ToDecimal(dt2.Rows[i]["SALDO"]) == 0)
                    {
                        dt2.Rows[i]["SALDO"] = "0.00";
                    }
                    if (Convert.ToString(dt2.Rows[i]["SALDO"]) != "")
                    {
                        totalsaldo += Convert.ToDecimal(dt2.Rows[i]["SALDO"]);
                    }
                }


                DataRow dr = dt2.NewRow();
                dr["CONCEPTO"] = " ";
                dr["CODMOVTO"] = "Total";
                if (TotalCuota == 0)
                {
                    dr["CUOTA"] = "Q.0" + TotalCuota.ToString("#,#.00#");
                }
                else
                {
                    dr["CUOTA"] = "Q." + TotalCuota.ToString("#,#.00#");
                }
                if (totalcargos == 0)
                {
                    dr["CARGOS"] = "Q.0" + totalcargos.ToString("#,#.00#");
                }
                else
                {
                    dr["CARGOS"] = "Q." + totalcargos.ToString("#,#.00#");
                }

                if (totalpagos == 0)
                {
                    dr["PAGOS"] = "Q.0" + totalpagos.ToString("#,#.00#");
                }
                else
                {
                    dr["PAGOS"] = "Q." + totalpagos.ToString("#,#.00#");
                }
                if (totalabonos == 0)
                {
                    dr["ABONOS"] = "Q.0" + totalabonos.ToString("#,#.00#");
                }
                else
                {
                    dr["ABONOS"] = "Q." + totalabonos.ToString("#,#.00#");
                }

                if (totalmora == 0)
                {
                    dr["MORA"] = "Q.0" + totalmora.ToString("#,#.00#");
                }
                else
                {
                    dr["MORA"] = "Q." + totalmora.ToString("#,#.00#");

                }

                if (totaladelanto == 0)
                {
                    dr["ADELANTO"] = "Q.0" + totaladelanto.ToString("#,#.00#");
                }
                else
                {
                    dr["ADELANTO"] = "Q." + totaladelanto.ToString("#,#.00#");
                }

                if (totalsaldo == 0)
                {
                    dr["SALDO"] = "Q.0" + totalsaldo.ToString("#,#.00#");
                }
                else
                {
                    dr["SALDO"] = "Q." + totalsaldo.ToString("#,#.00#");
                }


                dr["CARNET"] = carne;
                dr["CARRERA"] = carrera;


                dt2.Rows.Add(dr);
            }
            da.Dispose();
            return Newtonsoft.Json.JsonConvert.SerializeObject(dt2);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }


    /// <summary>
    /// Llena la tabal de Detalles del estado de cuenta de un alumno.
    /// </summary>
    /// <param name="carrera"></param>
    /// <param name="carne"></param>
    /// <returns>Devuelve Un Json con los datos que devuelve el StoredProcedure de DBAFISICC.EDOCTA.DETALLES_ESTADO_CUENTA</returns>
    [WebMethod]
    public static string llenar_detalles(string carrera, string carne)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);

        string ciclo = string.Empty;

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_CARRERA.ENTIDAD";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"]);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 4);
        cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;

        string entidad;
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            entidad = Convert.ToString(cmd.Parameters["VResp"].Value);

        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        if (entidad == "02")
        {
            cmd.Parameters.Clear();
            cmd = new OracleCommand();
            cmd.CommandText = "DBAFISICC.PKG_ALUMNO.CICLO_IDEA";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Connection = cn;
            cmd.BindByName = true;

            cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"]);
            cmd.Parameters.Add("PCARNET", carne);
            cmd.Parameters.Add("PCARRERA", carrera);
            cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 200);
            cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;

            try
            {
                cn.Open();

                cmd.ExecuteNonQuery();

                ciclo = Convert.ToString(cmd.Parameters["VResp"].Value);

            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cn.Close();
                cmd.Dispose();
            }
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.DETALLES_ESTADO_CUENTA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;


        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        if (entidad == "02")
        {
            cmd.Parameters.Add("PCICLO", ciclo);
        }
        else
        {
            cmd.Parameters.Add("PCICLO", null);
        }
        cmd.Parameters.Add("PUSUARIO", Convert.ToString(HttpContext.Current.Session["Usuario"]));
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            DataColumn dc = new DataColumn();
            dc.DataType = System.Type.GetType("System.String");
            dc.ColumnName = "SALDO";
            dt.Columns.Add(dc);
            string cargo;
            string abono;
            decimal total = 0;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                cargo = Convert.ToString(dt.Rows[i]["CARGO"]);
                abono = Convert.ToString(dt.Rows[i]["ABONO"]);
                if (cargo == "") { cargo = "0"; }
                if (abono == "") { abono = "0"; }

                total += Convert.ToDecimal(cargo) - Convert.ToDecimal(abono);

                if (total != 0)
                {
                    dt.Rows[i]["SALDO"] = total.ToString("#,#.00#");
                }
                else
                {
                    dt.Rows[i]["SALDO"] = "0.00";
                }

            }
            DataColumn column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "OPERACION2";
            dt.Columns.Add(column);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                dt.Rows[i]["OPERACION2"] = "<a class='btn-link OPERACION' style='color:black; font-size:11px' >" + dt.Rows[i]["OPERACION"] + "</a>";
            }


            da.Dispose();
            return Newtonsoft.Json.JsonConvert.SerializeObject(dt);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

    /// <summary>
    /// Evento que sirve para generar el reporte de Estado de Cuenta.
    /// </summary>
    /// <param name="send"></param>
    /// <param name="e"></param>
    protected void Imprimir_Click(object send, EventArgs e)
    {
        ReportDataSource RD = new ReportDataSource();
        RD.Value = Resumen(pcarnet, pcarrera);
        RD.Name = "DataSet1";

        ReportDataSource RD1 = new ReportDataSource();
        RD1.Value = Detalle(pcarnet, pcarrera);
        RD1.Name = "DataSet3";

        ReportDataSource RD2 = new ReportDataSource();
        RD2.Value = multas(pcarnet, pcarrera);
        RD2.Name = "DataSet5";

        ReportDataSource RD3 = new ReportDataSource();
        RD3.Value = cursos(pcarnet);
        RD3.Name = "DataSet4";

        ReportDataSource RD4 = new ReportDataSource();
        RD4.Value = foto(pcarnet);
        RD4.Name = "DataSet2";

        ReportParameter p1 = new ReportParameter("PUSUARIO", Convert.ToString(Session["Usuario"]));
        ReportParameter p2 = new ReportParameter("PCARNE", pcarnet);
        ReportParameter p3 = new ReportParameter("PCARRERA", NombreCarrera(pcarrera));
        ReportParameter p4 = new ReportParameter("PMTPOR", lblMtpor.InnerText);
        ReportParameter p5 = new ReportParameter("PMTQ", lblMtCant.InnerText);
        ReportParameter p6 = new ReportParameter("PCTPOR", lblCtpor.InnerText);
        ReportParameter p7 = new ReportParameter("PCTQ", lblCtCant.InnerText);
        ReportParameter p8 = new ReportParameter("PFIJA", lblCuotaFija.InnerText);
        ReportParameter p9 = new ReportParameter("PVARIABLE", lblCuotaVar.InnerText);
        ReportParameter p10 = new ReportParameter("PSUGERIDA", lblCuotaSug.InnerText);
        ReportParameter p11 = new ReportParameter("PTIPOBECA", lblDescBeca.InnerText);
        ReportParameter p12 = new ReportParameter("PPOR_CTAS", lblPorCtas.InnerText);
        ReportParameter p13 = new ReportParameter("PEXTRAORDINARIO", lblExtraordinario.InnerText);
        ReportParameter p14 = new ReportParameter("PSUGERIDO", lblSalSugerido.InnerText);
        ReportParameter p15 = new ReportParameter("PNOMBRE", nombreAlumno(pcarnet));
        ReportParameter p16 = new ReportParameter("PTOTALCICLO", ptotalpagar);
        ReportParameter p17 = new ReportParameter("PTOTALPAGARHOY", lblPagarHoy.InnerText);
        ReportParameter p18 = new ReportParameter("PTOTALMULTAS", lblTotalMultas.InnerText);
        ReportParameter p19 = new ReportParameter("PBECAVISIBLE", Convert.ToString(beca(pcarrera, pcarnet)));


        rvCuenta.Reset();
        string pathToFiles = Server.MapPath("/reportes/RepCuenta.rdlc");
        rvCuenta.LocalReport.DataSources.Clear();
        rvCuenta.LocalReport.DataSources.Add(RD);
        rvCuenta.LocalReport.DataSources.Add(RD1);
        rvCuenta.LocalReport.DataSources.Add(RD2);
        rvCuenta.LocalReport.DataSources.Add(RD3);
        rvCuenta.LocalReport.DataSources.Add(RD4);
        rvCuenta.LocalReport.ReportEmbeddedResource = "RepCuenta.rdlc";
        rvCuenta.LocalReport.ReportPath = pathToFiles;
        rvCuenta.LocalReport.SetParameters(new ReportParameter[] { p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19 });
        rvCuenta.LocalReport.Refresh();

        string reportType = "PDF";
        string mimeType;
        string encoding;
        string fileNameExtension;

        string deviceInfo =
         "<DeviceInfo>" +
        "  <OutputFormat>PDF</OutputFormat>" +
        "  <PageWidth>8.85827in</PageWidth>" +
        "  <PageHeight>11in</PageHeight>" +
        "  <MarginTop>0.03937in</MarginTop>" +
        "  <MarginLeft>0.03937in</MarginLeft>" +
        "  <MarginRight>0.03937in</MarginRight>" +
        "  <MarginBottom>0.03937in</MarginBottom>" +
        "</DeviceInfo>";

        Warning[] warnings;
        string[] streams;
        byte[] renderedBytes;

        //Render del reporte

        renderedBytes = rvCuenta.LocalReport.Render(
            reportType,
            deviceInfo,
            out mimeType,
            out encoding,
            out fileNameExtension,
            out streams,
            out warnings);

        string nombre = pcarrera + "_" + pcarnet + ".";
        Response.Clear();
        Response.ContentType = mimeType;
        Response.AddHeader("content-disposition", "attachment; filename=" + nombre + fileNameExtension);
        Response.BinaryWrite(renderedBytes);
        Response.End();
    }

    /// <summary>
    /// Sirve para traer el nombre de la carrera.
    /// </summary>
    /// <param name="carrera"></param>
    /// <returns>Devuelve un string con el nombre de la carrera</returns>
    protected string NombreCarrera(string carrera)
    {

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_CARRERA.NOMBRE";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 200);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PPENSUM", null);
        cmd.Parameters.Add("PTIPO", 4);
        cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            string VResp = Convert.ToString(cmd.Parameters["VResp"].Value);

            return VResp;


        }
        catch (Exception ex)
        {
            return "";
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

    }

    /// <summary>
    /// Sirve para consultar la tabla de resumen del Estado de Cuenta.
    /// </summary>
    /// <param name="carne"></param>
    /// <param name="carrera"></param>
    /// <returns>Devuelve un DataTable con la tabla de resumen de su estado de Cuenta.</returns>
    protected DataTable Resumen(string carne, string carrera)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.RESUMEN_ESTADO_CUENTA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"].ToString());
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt2 = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt2, RETVAL);

            decimal totalapagarhoy = 0;
            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                totalapagarhoy += Convert.ToDecimal(dt2.Rows[i]["SALDO"]);
            }
            if (totalapagarhoy != 0)
            {
                ptotalpagar = "Q." + totalapagarhoy.ToString("#,#.00#");
            }
            else
            {
                ptotalpagar = "Q.0.00";
            }
            da.Dispose();
            return dt2;
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

    /// <summary>
    /// Sirve para la tabla de Detalle del estado de Cuenta.
    /// </summary>
    /// <param name="carne"></param>
    /// <param name="carrera"></param>
    /// <returns>Devuelve un DataTable que llena el Detalle del Estado de Cuenta</returns>
    protected DataTable Detalle(string carne, string carrera)
    {

        string ciclo = string.Empty;

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_CARRERA.ENTIDAD";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"]);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 4);
        cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;

        string entidad;
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            entidad = Convert.ToString(cmd.Parameters["VResp"].Value);

        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

        if (entidad == "02")
        {
            cmd.Parameters.Clear();
            cmd = new OracleCommand();
            cmd.CommandText = "DBAFISICC.PKG_ALUMNO.CICLO_IDEA";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Connection = cn;
            cmd.BindByName = true;

            cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"]);
            cmd.Parameters.Add("PCARNET", carne);
            cmd.Parameters.Add("PCARRERA", carrera);
            cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 200);
            cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;

            try
            {
                cn.Open();

                cmd.ExecuteNonQuery();

                ciclo = Convert.ToString(cmd.Parameters["VResp"].Value);

            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cn.Close();
                cmd.Dispose();
            }
        }

        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.DETALLES_ESTADO_CUENTA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;


        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        if (entidad == "02")
        {
            cmd.Parameters.Add("PCICLO", ciclo);
        }
        else
        {
            cmd.Parameters.Add("PCICLO", null);
        }
        cmd.Parameters.Add("PUSUARIO", Convert.ToString(HttpContext.Current.Session["Usuario"]));
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            DataColumn dc = new DataColumn();
            dc.DataType = System.Type.GetType("System.String");
            dc.ColumnName = "SALDO";
            dt.Columns.Add(dc);
            string cargo;
            string abono;
            decimal total = 0;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                cargo = Convert.ToString(dt.Rows[i]["CARGO"]);
                abono = Convert.ToString(dt.Rows[i]["ABONO"]);
                if (cargo == "") { cargo = "0"; }
                if (abono == "") { abono = "0"; }

                total += Convert.ToDecimal(cargo) - Convert.ToDecimal(abono);

                if (total != 0)
                {
                    dt.Rows[i]["SALDO"] = total.ToString("#,#.00#");
                }
                else
                {
                    dt.Rows[i]["SALDO"] = "0.00";
                }
            }
            DataColumn column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "OPERACION2";
            dt.Columns.Add(column);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                dt.Rows[i]["OPERACION2"] = "<a class='btn-link OPERACION' style='color:black; font-size:11px' >" + dt.Rows[i]["OPERACION"] + "</a>";
            }

            da.Dispose();
            return dt;
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

    /// <summary>
    ///  Sirve para llenar la tabla de cursos.
    /// </summary>
    /// <param name="carne"></param>
    /// <returns>Devuelve un DataTable con los cursos asignados del alumno.</returns>
    protected DataTable cursos(string carne)
    {
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_ALUMNO.SEL_CURSOSASIG";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);
            da.Dispose();

            return dt;
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

    /// <summary>
    /// Sirve para obtener  la foto del alumno
    /// </summary>
    /// <param name="carne"></param>
    /// <returns>Devuelve un DataTable con la foto del alumno.</returns>
    protected DataTable foto(string carne)
    {
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_ALUMNO.FOTO";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.InitialLOBFetchSize = -1;
        cmd.InitialLONGFetchSize = -1;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);
            da.Dispose();

            return dt;
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

    /// <summary>
    /// Devuelve las multas de un alumno.
    /// </summary>
    /// <param name="carne"></param>
    /// <param name="carrera"></param>
    /// <returns>Devuelve Un DataTable con las multas de un alumno.</returns>
    protected DataTable multas(string carne, string carrera)
    {
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.LLAMASALDO_A_HOY_WEB";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", null);
        cmd.Parameters.Add("PSALDO", OracleDbType.Decimal, 22);
        cmd.Parameters["PSALDO"].Direction = ParameterDirection.InputOutput;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleDecimal PSALDO = (OracleDecimal)(cmd.Parameters["PSALDO"].Value);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.MULTASEDOCTA";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PEDOCTA", "0");

        try
        {
            cn.Open();
            cmd.ExecuteNonQuery();
        }
        catch (Exception ex)
        {
            HttpContext.Current.Response.Redirect("login.aspx");
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }


        cmd.Parameters.Clear();
        cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.SEL_MULTASTMP";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("PUSUARIO", Convert.ToString(HttpContext.Current.Session["Usuario"]));
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt = new DataTable();
        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);
            da.Dispose();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
        return dt;
    }

    /// <summary>
    ///  Sirve para obtener  el Nombre completo del alumno.
    /// </summary>
    /// <param name="carne"></param>
    /// <returns>Devuelve un string con el nombre del alumno.</returns>
    protected string nombreAlumno(string carne)
    {
        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_ALUMNO.NOMBRE";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 200);
        cmd.Parameters.Add("PCARNET", carne);
        cmd.Parameters.Add("POPCION", 2);
        cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            string VResp = Convert.ToString(cmd.Parameters["VResp"].Value);
            return VResp;
        }
        catch (Exception ex)
        {
            return "";
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }


    [WebMethod]
    public static string solicitud(string paso, string carnet, string carrera, string tramite)
    {

        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.PKG_CATALOGO.SOLICITUDES_FINANCIERAS";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PPASO", paso);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PCARNET", carnet);
        cmd.Parameters.Add("PTRAMITE", tramite);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter();
            da.Fill(dt, RETVAL);

            da.Dispose();

            DataRow fila;

            if (dt.Rows.Count < 1)
            {
                fila = dt.NewRow();

                fila["SOLICITUD"] = "Sin Solicitudes";
                dt.Rows.Add(fila);
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(dt);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

    }


    [WebMethod]
    public static string solicitud2(string carnet, string carrera, string tramite)
    {

        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);

        OracleCommand cmd = new OracleCommand();
        DataTable dt = new DataTable();


        try
        {
            cn.Open();

            for (int i = 0; i < 2; i++)
            {

                cmd.CommandText = "DBAFISICC.PKG_CATALOGO.SOLICITUDES_FINANCIERAS";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = cn;
                cmd.BindByName = true;

                cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
                cmd.Parameters.Add("PPASO", i == 0 ? "6" : "8");
                cmd.Parameters.Add("PCARRERA", carrera);
                cmd.Parameters.Add("PCARNET", carnet);
                cmd.Parameters.Add("PTRAMITE", tramite);
                cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

                cmd.ExecuteNonQuery();

                OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

                OracleDataAdapter da = new OracleDataAdapter();
                da.Fill(dt, RETVAL);

                da.Dispose();

                cmd.Parameters.Clear();

            }

            if (dt.Rows.Count < 1)
            {
                DataRow fila;
                fila = dt.NewRow();

                fila["SOLICITUD"] = "Sin Solicitudes";
                dt.Rows.Add(fila);
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(dt);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

    }

    [WebMethod]
    public static string llenarExoneracion(string carnet, string carrera)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);


        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.EDOCTA_TIPOEXONERACIONES";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("RETVAL", OracleDbType.RefCursor, 200);
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PCARNET", carnet);
        cmd.Parameters["RETVAL"].Direction = ParameterDirection.Output;

        DataTable dt = new DataTable();
        DataTable dt2 = new DataTable();


        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            OracleRefCursor RETVAL = (OracleRefCursor)(cmd.Parameters["RETVAL"].Value);

            OracleDataAdapter da = new OracleDataAdapter();

            da.Fill(dt, RETVAL);

            da.Dispose();

            dt2.Columns.Add("CORRELATIVO", typeof(String));
            dt2.Columns.Add("CARGO_ABONO", typeof(String));
            dt2.Columns.Add("CODMOVTO", typeof(String));
            dt2.Columns.Add("MOVIMIENTO", typeof(String));
            dt2.Columns.Add("CURSO", typeof(String));
            dt2.Columns.Add("NOMBRE", typeof(String));
            dt2.Columns.Add("FECHA", typeof(DateTime));
            dt2.Columns.Add("SALDO", typeof(String));
            dt2.Columns.Add("CENTRO", typeof(String));
            dt2.Columns.Add("MONTO", typeof(String));
            dt2.Columns.Add("PAGOS", typeof(String));
            dt2.Columns.Add("INICIO", typeof(String));
            dt2.Columns.Add("SELECCION", typeof(String));


            dt.Columns.Add("MONTO", typeof(String));
            dt.Columns.Add("PAGOS", typeof(String));
            dt.Columns.Add("INICIO", typeof(String));
            dt.Columns.Add("SELECCION", typeof(String));

            DataRow filas;
            bool agrega;
            bool abono;


            for (int i = 0; i < dt.Rows.Count; i++)
            {
                agrega = false;
                abono = false;

                if (dt2.Rows.Count > 0)
                {
                    for (int j = 0; j < dt2.Rows.Count; j++)
                    {

                        if (agrega == false)
                        {

                            if (Convert.ToString(dt.Rows[i]["CODMOVTO"]) == "MU")
                            {
                                dt.Rows[i]["CURSO"] = "";
                                dt.Rows[i]["NOMBRE"] = "";
                            }
                            else if (Convert.ToString(dt.Rows[i]["CODMOVTO"]) == "MTB")
                            {
                                dt.Rows[i]["CODMOVTO"] = "MT";
                                dt.Rows[i]["MOVIMIENTO"] = "MATRICULA";
                            }

                            if (Convert.ToString(dt.Rows[i]["CARGO_ABONO"]) == "A")
                            {
                                abono = true;
                            }

                            if (Convert.ToString(dt2.Rows[j]["CODMOVTO"]) == Convert.ToString(dt.Rows[i]["CODMOVTO"]) && Convert.ToString(dt2.Rows[j]["CURSO"]) == Convert.ToString(dt.Rows[i]["CURSO"]))
                            {

                                if (abono == true)
                                {
                                    dt.Rows[i]["SALDO"] = Convert.ToString(Convert.ToDouble(dt.Rows[i]["SALDO"]) * (-1));

                                    dt2.Rows[j]["SALDO"] = Convert.ToString(Convert.ToDouble(dt2.Rows[j]["SALDO"]) + Convert.ToDouble(dt.Rows[i]["SALDO"]));
                                }
                            }
                            else
                            {
                                if (abono == false)
                                {

                                    dt.Rows[i]["MONTO"] = "<input type='text' class='form-control input-sm texto' maxlength='11' onkeypress='return onlyNumbers(event)' style='text-align: center' value='' />";
                                    dt.Rows[i]["PAGOS"] = "<input type='text' class='form-control input-sm texto' maxlength='1' onkeypress='return onlyNumbers(event)' style='text-align: center' value='' />";
                                    dt.Rows[i]["INICIO"] = "<input type='text' class='form-control input-sm texto' maxlength='1' onkeypress='return onlyNumbers(event)' style='text-align: center' value='' />";
                                    dt.Rows[i]["SELECCION"] = "0";

                                    filas = dt2.NewRow();

                                    filas["CORRELATIVO"] = dt.Rows[i]["CORRELATIVO"];
                                    filas["CARGO_ABONO"] = dt.Rows[i]["CARGO_ABONO"];
                                    filas["CODMOVTO"] = dt.Rows[i]["CODMOVTO"];
                                    filas["MOVIMIENTO"] = dt.Rows[i]["MOVIMIENTO"];
                                    filas["CURSO"] = dt.Rows[i]["CURSO"];
                                    filas["NOMBRE"] = dt.Rows[i]["NOMBRE"];
                                    filas["FECHA"] = dt.Rows[i]["FECHA"];
                                    filas["SALDO"] = dt.Rows[i]["SALDO"];
                                    filas["CENTRO"] = dt.Rows[i]["CENTRO"];
                                    filas["MONTO"] = dt.Rows[i]["MONTO"];
                                    filas["PAGOS"] = dt.Rows[i]["PAGOS"];
                                    filas["INICIO"] = dt.Rows[i]["INICIO"];
                                    filas["SELECCION"] = dt.Rows[i]["SELECCION"];


                                    dt2.Rows.Add(filas);
                                    agrega = true;
                                }

                            }


                        }

                        if (Convert.ToDouble(dt2.Rows[j]["SALDO"]) <= 0)
                        {
                            dt2.Rows.Remove(dt2.Rows[j]);
                        }
                    }
                }
                else
                {

                    dt.Rows[i]["MONTO"] = "<input type='text' class='form-control input-sm texto' maxlength='11' onkeypress='return onlyNumbers(event)' style='text-align: center' value='' />";
                    dt.Rows[i]["PAGOS"] = "<input type='text' class='form-control input-sm texto' maxlength='1' onkeypress='return onlyNumbers(event)' style='text-align: center' value='' />";
                    dt.Rows[i]["INICIO"] = "<input type='text' class='form-control input-sm texto' maxlength='1' onkeypress='return onlyNumbers(event)' style='text-align: center' value='' />";
                    dt.Rows[i]["SELECCION"] = "0";

                    filas = dt2.NewRow();

                    filas["CORRELATIVO"] = dt.Rows[i]["CORRELATIVO"];
                    filas["CARGO_ABONO"] = dt.Rows[i]["CARGO_ABONO"];
                    filas["CODMOVTO"] = dt.Rows[i]["CODMOVTO"];
                    filas["MOVIMIENTO"] = dt.Rows[i]["MOVIMIENTO"];
                    filas["CURSO"] = dt.Rows[i]["CURSO"];
                    filas["NOMBRE"] = dt.Rows[i]["NOMBRE"];
                    filas["FECHA"] = dt.Rows[i]["FECHA"];
                    filas["SALDO"] = dt.Rows[i]["SALDO"];
                    filas["CENTRO"] = dt.Rows[i]["CENTRO"];
                    filas["MONTO"] = dt.Rows[i]["MONTO"];
                    filas["PAGOS"] = dt.Rows[i]["PAGOS"];
                    filas["INICIO"] = dt.Rows[i]["INICIO"];
                    filas["SELECCION"] = dt.Rows[i]["SELECCION"];


                    dt2.Rows.Add(filas);
                    agrega = true;

                }


            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(dt2);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }

    }

    [WebMethod]
    public static string exonerar(string observaciones, string centro, string solicitud, string monto, string curso, string codigo, string carrera, string carnet)
    {
        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);

        OracleCommand cmd = new OracleCommand();
        cmd.CommandText = "DBAFISICC.EDOCTA.EXONERACION";
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Connection = cn;
        cmd.BindByName = true;

        cmd.Parameters.Add("POBSERVACIONES", observaciones);

        cmd.Parameters.Add("PCENTRO", centro != "" ? centro : carrera);
        cmd.Parameters.Add("PSOLICITUD", solicitud);
        cmd.Parameters.Add("PEXONERACION", 1);
        cmd.Parameters.Add("PMONTO", Convert.ToDouble(monto));
        cmd.Parameters.Add("PCURSO", curso);
        cmd.Parameters.Add("PCODMOVTO", codigo);
        cmd.Parameters.Add("PPENSUM", "");
        cmd.Parameters.Add("PCARRERA", carrera);
        cmd.Parameters.Add("PCARNET", carnet);
        cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"]);
        cmd.Parameters.Add("VResp", OracleDbType.Varchar2, 200);
        cmd.Parameters["VResp"].Direction = ParameterDirection.ReturnValue;

        try
        {
            cn.Open();

            cmd.ExecuteNonQuery();

            string VResp = Convert.ToString(cmd.Parameters["VResp"].Value);

            return VResp;
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }


    [WebMethod]
    public static string tr_fracc(string observaciones, string centro, string solicitud, string monto, string curso, string codigo, string carrera, string carnet, string fraccionamiento, string inicio)
    {

        OracleConnection cn = new OracleConnection(ConfigurationManager.ConnectionStrings["Galileo"].ConnectionString);
        OracleCommand cmd = new OracleCommand();
        cn.Open();

          string PSQLCODE; 

        try
        {
            for (int i = 0; i < 2; i++)
            {

                cmd.CommandText = "DBAFISICC.EDOCTA.FRACCIONAMIENTO";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = cn;
                cmd.BindByName = true;

                cmd.Parameters.Add("PUSUARIO", HttpContext.Current.Session["Usuario"]);
                cmd.Parameters.Add("PCARNET", carnet);
                cmd.Parameters.Add("PCARRERA", carrera);
                cmd.Parameters.Add("PPENSUM", "");
                cmd.Parameters.Add("PCODMOVTO", i == 0 ? codigo : "MA");
                cmd.Parameters.Add("PCURSO", curso);
                cmd.Parameters.Add("PMONTO", Convert.ToDouble(monto));
                cmd.Parameters.Add("PSOLICITUD", solicitud);
                cmd.Parameters.Add("PFRACCION", i== 0 ? "" : fraccionamiento);
                cmd.Parameters.Add("PINI_FRAC", i == 0 ? "" : inicio);
                cmd.Parameters.Add("PCENTRO", centro != "" ? centro : carrera);
                cmd.Parameters.Add("PTIPO", i == 0 ? "A" : "C");
                cmd.Parameters.Add("POBSERVACIONES", observaciones);
                cmd.Parameters.Add("PSQLCODE", OracleDbType.Decimal, 22);
                cmd.Parameters["PSQLCODE"].Direction = ParameterDirection.Output;



                cmd.ExecuteNonQuery();

                PSQLCODE = Convert.ToString(cmd.Parameters["PSQLCODE"].Value);

                cmd.Parameters.Clear();

            }

            return "0";
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            cn.Close();
            cmd.Dispose();
        }
    }

}