
#include <include/symbolic_functions.h>
#include <include/amici.h>
#include <string.h>
#include <include/udata.h>
#include <include/tdata.h>
#include "model_neuron_o2_w.h"

int deltax_model_neuron_o2(realtype t, int ie, N_Vector x, N_Vector xdot, N_Vector xdot_old, void *user_data, TempData *tdata) {
int status = 0;
UserData *udata = (UserData*) user_data;
realtype *x_tmp = N_VGetArrayPointer(x);
realtype *xdot_tmp = N_VGetArrayPointer(xdot);
realtype *xdot_old_tmp = N_VGetArrayPointer(xdot_old);
memset(tdata->deltax,0,sizeof(realtype)*10);
status = w_model_neuron_o2(t,x,NULL,user_data);
              switch(ie) { 
              case 0: {
  tdata->deltax[0] = -udata->p[2]-x_tmp[0];
  tdata->deltax[1] = udata->p[3];
  tdata->deltax[2] = -(x_tmp[2]*(udata->p[2]*5.0+udata->p[3]+x_tmp[0]*5.0-(udata->p[2]*udata->p[2])*(1.0/2.5E1)+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2);
  tdata->deltax[3] = -(x_tmp[2]*(udata->p[0]*(udata->p[3]+x_tmp[1]+udata->p[1]*udata->p[2])-udata->p[0]*(x_tmp[1]-udata->p[1]*x_tmp[0])))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2);
  tdata->deltax[4] = -(x_tmp[4]*(udata->p[2]*5.0+udata->p[3]+x_tmp[0]*5.0-(udata->p[2]*udata->p[2])*(1.0/2.5E1)+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2);
  tdata->deltax[5] = -(x_tmp[4]*(udata->p[0]*(udata->p[3]+x_tmp[1]+udata->p[1]*udata->p[2])-udata->p[0]*(x_tmp[1]-udata->p[1]*x_tmp[0])))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2);
  tdata->deltax[6] = -(x_tmp[6]*(udata->p[2]*5.0+udata->p[3]+x_tmp[0]*5.0-(udata->p[2]*udata->p[2])*(1.0/2.5E1)+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2)-1.0;
  tdata->deltax[7] = -(x_tmp[6]*(udata->p[0]*(udata->p[3]+x_tmp[1]+udata->p[1]*udata->p[2])-udata->p[0]*(x_tmp[1]-udata->p[1]*x_tmp[0])))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2);
  tdata->deltax[8] = -(x_tmp[8]*(udata->p[2]*5.0+udata->p[3]+x_tmp[0]*5.0-(udata->p[2]*udata->p[2])*(1.0/2.5E1)+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2);
  tdata->deltax[9] = -(x_tmp[8]*(udata->p[0]*(udata->p[3]+x_tmp[1]+udata->p[1]*udata->p[2])-udata->p[0]*(x_tmp[1]-udata->p[1]*x_tmp[0])))/(udata->k[1]+x_tmp[0]*5.0-x_tmp[1]+(x_tmp[0]*x_tmp[0])*(1.0/2.5E1)+1.4E2)+1.0;

              } break;

              } 
return(status);

}


