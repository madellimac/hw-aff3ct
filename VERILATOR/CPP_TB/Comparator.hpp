#ifndef COMPARATOR_H
#define COMPARATOR_H

#include "aff3ct.hpp"

namespace aff3ct
{
namespace module
{

class Comparator  : public Module {

private:
    
    int frame_size;

public:

    Comparator(int frame_size);
    virtual ~Comparator();

protected:

    virtual void compare(int* input1, int* input2, int *output, const int frame_id);

};
}
}

#endif // COMPARATOR_H